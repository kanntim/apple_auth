import 'dart:async';
import 'dart:convert';

import 'package:authentication_repository/src/models/request_models.dart';
import 'package:authentication_repository/src/models/server_answer_model.dart';
import 'package:flutter/services.dart';
import 'package:http_util/http_util.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  AuthenticationRepository({required this.httpClient});
  final _controller = StreamController<AuthenticationStatus>();
  static const platform = MethodChannel('com.test/generateRSA');
  final HttpUtil httpClient;

  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<RegisterSuccessModel> registerOnServer(RegisterRequest request) async {
    final result =
        await httpClient.post('/ios.php', data: jsonEncode(request.toMap()));
    print(RegisterSuccessModel.fromJson(result).errorStatus);

    return RegisterSuccessModel.fromJson(result);
  }

  Future<LoginSuccessModel> loginInServer(LoginRequest request) async {

    final result =
        await httpClient.post('/ios.php', data: jsonEncode(request.toMap()));

    if (result['error_code'] != 1) {
      return LoginSuccessModel.fromJson(result);
    }
    _controller.add(AuthenticationStatus.authenticated);
    return LoginSuccessModel.fromJson(result);
  }

  void logOut() {
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() => _controller.close();


  Future _generateRSAKeyPair() async {
    try {
      final Map<dynamic, dynamic>? data =
      await platform.invokeMethod('generateKeys');
    } on PlatformException catch (e) {
      rethrow;
    }
  }
  Future makeRegisterRequestNative() async {
    try {
      final Map<dynamic, dynamic>? data =
      await platform.invokeMethod('makeRegisterRequest');
      final request = RegisterRequest.fromMap((data as Map).cast<String, dynamic>());
      final result = await httpClient.post('/ios.php', data: jsonEncode(request.toMap()));
      return RegisterSuccessModel.fromJson(result);
    } on PlatformException catch (e) {
      rethrow;
    }
  }
  Future makeLoginRequestNative() async {
    try {
      final Map<dynamic, dynamic>? data =
      await platform.invokeMethod('makeLoginRequest');
      final request = LoginRequest.fromMap((data as Map).cast<String, dynamic>());
      final result = await httpClient.post('/ios.php', data: jsonEncode(request.toMap()));
      return LoginSuccessModel.fromJson((result as Map).cast<String, dynamic>());
    } on PlatformException catch (e) {
      rethrow;
    }
  }
}
