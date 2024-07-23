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
        "signature": "\"$signature\"",
      };
}
