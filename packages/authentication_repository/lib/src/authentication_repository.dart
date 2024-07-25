import 'dart:async';
import 'dart:convert';

import 'package:authentication_repository/src/models/request_models.dart';
import 'package:authentication_repository/src/models/server_answer_model.dart';
import 'package:http_util/http_util.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  AuthenticationRepository({required this.httpClient});
  final _controller = StreamController<AuthenticationStatus>();
  final HttpUtil httpClient;

  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<RegisterSuccessModel> registerOnServer({
    required String udid,
    required String rnd,
    required String signature,
    required String publicKey,
  }) async {
    final request = RegisterRequest(
      udid: udid,
      rnd: rnd,
      signature: signature,
      pmk: publicKey,
    );

    final result =
        await httpClient.post('/ios.php', data: jsonEncode(request.toMap()));
    print(RegisterSuccessModel.fromJson(result).errorStatus);

    return RegisterSuccessModel.fromJson(result);
  }

  Future<LoginSuccessModel> loginInServer({
    required String udid,
    required String login,
    String email = '',
    required String rnd,
    required String signature,
    required String publicKey,
  }) async {
    final request = LoginRequest(
      login: login,
      email: email,
      udid: udid,
      rnd: rnd,
      signature: signature,
      pmk: publicKey,
    );
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
}
