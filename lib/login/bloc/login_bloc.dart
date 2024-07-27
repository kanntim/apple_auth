import 'package:apple_auth/login/view/login_form.dart';
import 'package:apple_id_auth_repository/apple_id_auth_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:rsa_manager/rsa_manager.dart';
import 'package:user_repository/user_repository.dart';
import 'package:uuid/v4.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required AppleIdAuthRepository appleIdAuthRepository,
    required AuthenticationRepository authenticationRepository,
    required UserRepository userRepository,
  })  : _appleIdAuthRepository = appleIdAuthRepository,
        _authenticationRepository = authenticationRepository,
        _userRepository = userRepository,
        super(const LoginState()) {
    on<LoginSubmitted>(_onSubmitted);
    on<LoginRealizationChanged>(_onRealizationChanged);
  }
  final AppleIdAuthRepository _appleIdAuthRepository;
  final AuthenticationRepository _authenticationRepository;
  final UserRepository _userRepository;

  Future _onRealizationChanged(
    LoginRealizationChanged event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(realization: event.type));
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(
        status: SubmissionStatus.inProgress, realization: state.realization));
    try {
      final appleCredential =
          await _appleIdAuthRepository.getAppleIDCredential();

      if (appleCredential.email == null &&
          appleCredential.userIdentifier.isEmpty) {
        emit(state.copyWith(
            status: SubmissionStatus.failure, realization: state.realization));
        return;
      }

      final login = appleCredential.userIdentifier;
      final String udid = await FlutterUdid.udid;
      final String? email = appleCredential.email;



      final user =
          await _userRepository.getUser(appleCredential.userIdentifier);
      late RequestModel request;

      if (user == null) {
        if (state.realization == RealizationType.native) {
          final data =
          await RsaManager.makeRegisterRequest(login: login, udid: udid, email: email);
          request =
              RegisterRequest.fromMap((data as Map).cast<String, dynamic>());
        } else {
          final String udid = await FlutterUdid.udid;
          final String rnd = const UuidV4().generate().toLowerCase();
          final String concat = udid + rnd;
          final String signature = CryptoUtilsManager().signData(concat);
          final String publicKey = CryptoUtilsManager().pemRsaPublicKey;
          request = RegisterRequest(
              udid: udid, rnd: rnd, signature: signature, pmk: publicKey);
        }
        final registerResult =
            await _authenticationRepository.registerOnServer(request as RegisterRequest);

        if (registerResult.error != 1) {

          emit(state.copyWith(
              status: SubmissionStatus.failure,
              serverAnswer: registerResult,
              realization: state.realization));
          return;
        }
      }


      if (state.realization == RealizationType.native) {
        final data =
        await RsaManager.makeLoginRequest(login: login, udid: udid, email: email);final request =
            LoginRequest.fromMap((data as Map).cast<String, dynamic>());
      } else {
        final String udid = await FlutterUdid.udid;
        final String rnd = const UuidV4().generate().toLowerCase();
        final String concat = udid + rnd;
        final String signature = CryptoUtilsManager().signData(concat);
        final String publicKey = CryptoUtilsManager().pemRsaPublicKey;
        request = RegisterRequest(
            udid: udid, rnd: rnd, signature: signature, pmk: publicKey);
      }

      final loginResult = await _authenticationRepository.loginInServer(request as LoginRequest);

      if (loginResult.error != 1) {
        emit(state.copyWith(
            status: SubmissionStatus.failure, serverAnswer: loginResult));
        return;
      }
      //TODO: save private key or random seed for login in future
      _userRepository.setUser(userId: appleCredential.userIdentifier, login: state.login);

      emit(state.copyWith(
          status: SubmissionStatus.success,
          isHasAppleId: true,
          serverAnswer: loginResult));
    } catch (_) {
      emit(state.copyWith(
        status: SubmissionStatus.failure,
      ));
      rethrow;
    }
  }
}
