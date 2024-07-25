import 'package:apple_auth/login/view/login_form.dart';
import 'package:apple_id_auth_repository/apple_id_auth_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:key_manager/key_manager.dart';
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
    emit(state.copyWith(status: SubmissionStatus.inProgress));
    try {
      final appleCredential =
          await _appleIdAuthRepository.getAppleIDCredential();

      if (appleCredential.email == null ||
          appleCredential.userIdentifier.isNotEmpty) {
        emit(state.copyWith(status: SubmissionStatus.failure));
        return;
      }

      final udid = await FlutterUdid.udid;
      String rnd = const UuidV4().generate().toLowerCase();
      String concat = udid + rnd;
      String signature = CryptoUtilsManager().signData(concat);
      String publicKey = CryptoUtilsManager().pemRsaPublicKey;
      final user = await _userRepository.getUser(udid);

      if (user == null) {
        final registerResult = await _authenticationRepository.registerOnServer(
            udid: udid, rnd: rnd, signature: signature, publicKey: publicKey);
        if (registerResult.error != 1) {
          emit(state.copyWith(
              status: SubmissionStatus.failure, serverAnswer: registerResult));
          return;
        }
      }

      rnd = const UuidV4().generate().toLowerCase();
      concat = udid + rnd;
      signature = CryptoUtilsManager().signData(concat);
      publicKey = CryptoUtilsManager().pemRsaPublicKey;

      final loginResult = await _authenticationRepository.loginInServer(
          udid: udid,
          login: state.login,
          rnd: rnd,
          signature: signature,
          publicKey: publicKey);

      if (loginResult.error != 1) {
        emit(state.copyWith(
            status: SubmissionStatus.failure, serverAnswer: loginResult));
        return;
      }

      _userRepository.setUser(userId: udid, login: state.login);

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
