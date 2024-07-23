import 'dart:convert';

import 'package:apple_auth/http_service.dart';
import 'package:apple_auth/request_models.dart';
import 'package:apple_auth/server_answer_model.dart';
import 'package:apple_id_auth_repository/apple_id_auth_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:key_manager/key_manager.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required AppleIdAuthRepository appleIdAuthRepository,
    required AuthenticationRepository authenticationRepository,
  })  : _appleIdAuthRepository = appleIdAuthRepository,
        _authenticationRepository = authenticationRepository,
        super(const LoginState()) {
    on<LoginSubmitted>(_onSubmitted);
    on<LoginTestCrypto>(_onTestCrypto);
  }
  final AppleIdAuthRepository _appleIdAuthRepository;
  final AuthenticationRepository _authenticationRepository;

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
      }
      final result = await requestFunc3();

      /*await _authenticationRepository.logIn(
        udid: state.udid,
        login: state.login,
      );*/
      emit(state.copyWith(
          status: SubmissionStatus.success,
          isHasAppleId: true,
          serverAnswer: result));
    } catch (_) {
      emit(state.copyWith(
        status: SubmissionStatus.failure,
      ));
    }
  }

  void _onTestCrypto(
    LoginTestCrypto event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: SubmissionStatus.inProgress));
    try {
      final res = await SignInWithApple.getKeychainCredential();
      print(res);
      /*final result = await requestFunc();
      emit(state.copyWith(
          status: SubmissionStatus.success, serverAnswer: result));*/
    } catch (_) {
      emit(state.copyWith(
        status: SubmissionStatus.failure,
      ));
      rethrow;
    }
  }

  Future<ServerAnswerModel> requestFunc3() async {
    const udid =
        '933E8F70-D9B6-409D-8A48-1D8113C2D3B6'; //'' //await FlutterUdid.udid;
    final rnd = const UuidV4().generate();
    final concat = udid + rnd;
    final signature = CryptoUtilsManager().signData(concat);
    final publicKey = CryptoUtilsManager().pemRsaPublicKey;

    final request = RegisterRequest(
      udid: udid,
      rnd: rnd,
      signature: signature,
      pmk: publicKey,
    );
    final result =
        await HttpUtil().post('/ios.php', data: jsonEncode(request.toMap()));
    print(ServerAnswerModel.fromJson(result).errorStatus);
    return ServerAnswerModel.fromJson(result);
  }

  Future<ServerAnswerModel> requestFunc2() async {
    const udid =
        '933E8F70-D9B6-409D-8A48-1D8113C2D3B6'; //'' //await FlutterUdid.udid;
    final rnd = const UuidV4().generate();
    final concat = udid + rnd;
    final signature = await RsaManager().createHash(concat);
    final publicKey = RsaManager().base64PemPubKey;
    final request = RegisterRequest(
      udid: udid,
      rnd: rnd,
      signature: signature,
      pmk: publicKey,
    );
    final result =
        await HttpUtil().post('/ios.php', data: jsonEncode(request.toMap()));
    print(ServerAnswerModel.fromJson(result).errorStatus);
    return ServerAnswerModel.fromJson(result);
  }

  Future<ServerAnswerModel> requestFunc() async {
    final udid = '933E8F70-D9B6-409D-8A48-1D8113C2D3B6';
    ; //await FlutterUdid.udid;
    final rnd = const Uuid().v4();
    final concat = udid + rnd;
    final signature = RSAGenerator().createSignature(concat);
    final publicKey = RSAGenerator().base64PemPubKey();

    final request = RegisterRequest(
      udid: udid,
      rnd: rnd,
      signature: signature,
      pmk: publicKey,
    );
    final result =
        await HttpUtil().post('/ios.php', data: jsonEncode(request.toMap()));
    print(ServerAnswerModel.fromJson(result).errorStatus);
    return ServerAnswerModel.fromJson(result);
  }
}
