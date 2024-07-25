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

        /// Tests
        "lang": "en",
        "hard_model": "iPhone",
        "hard_os": "17.5.1",
        "hard_name": "iPhone",
        "hard_lmodel": "iPhone",
        "hard_fmodel": "2BFAFA6D-0E85-1898-A068-E723AA1539D9",
      };
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
}
