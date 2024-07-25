class RequestModel {
  const RequestModel(
      {required this.oper,
      required this.udid,
      required this.rnd,
      required this.signature});
  final String oper;
  final String udid;
  final String rnd;
  final String signature;
}

class RegisterRequest extends RequestModel {
  const RegisterRequest({
    required super.udid,
    required super.rnd,
    required super.signature,
    required this.pmk,
  }) : super(oper: 'init');
  final String pmk;

  Map<String, dynamic> toMap() => {
        "oper": oper,
        "udid": udid,
        "rnd": rnd,
        "pmk": pmk,
        "signature": signature,
      };

  factory RegisterRequest.fromMap(Map<String, dynamic> map) {
    return RegisterRequest(
      udid: map['udid'],
      rnd: map['rnd'],
      signature: map['signature'],
      pmk: map['pmk'],
    );
  }
}

class LoginRequest extends RequestModel {
  const LoginRequest({
    required super.udid,
    required super.rnd,
    required super.signature,
    required this.pmk,
    required this.login,
    this.email,
  }) : super(oper: 'login_apple_id');
  final String pmk;
  final String login;
  final String? email;

  Map<String, dynamic> toMap() => {
        "oper": oper,
        "udid": udid,
        "rnd": rnd,
        //"pmk": pmk,
        "signature": signature,
        "login": login,
        "email": email ?? '',
        "lang": "en",
      };

  factory LoginRequest.fromMap(Map<String, dynamic> map) {
    return LoginRequest(
      udid: map['udid'],
      rnd: map['rnd'],
      signature: map['signature'],
      pmk: map['pmk'],
      login: map['login'],
      email: map['email'],
    );
  }
}
