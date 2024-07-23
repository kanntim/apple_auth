import 'package:equatable/equatable.dart';

class ServerAnswerModel extends Equatable {
  const ServerAnswerModel({
    required this.error,
    this.errorStatus,
    this.workStatus,
  });
  final int error;
  final String? errorStatus;
  final UserModel? workStatus;

  factory ServerAnswerModel.fromJson(Map<String, dynamic> json) {
    return ServerAnswerModel(
      error: json['error_code'],
      errorStatus: json['error_status'],
      workStatus: (json['work_status'] != null)
          ? UserModel.fromJson(json['work_status'])
          : null,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [errorStatus, workStatus, error];
}

class UserModel {
  const UserModel({
    required this.login,
    required this.udid,
  });
  final String login;
  final String udid;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      login: json['login'],
      udid: json['udid'],
    );
  }
}
