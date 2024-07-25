import 'package:equatable/equatable.dart';

abstract class ServerAnswerModel<T> extends Equatable {
  const ServerAnswerModel({
    required this.error,
    this.errorStatus,
    this.workStatus,
  });
  final int error;
  final String? errorStatus;
  final T? workStatus;

  @override
  List<Object?> get props => [];
}

class LoginSuccessModel extends ServerAnswerModel<WorkStatus> {
  const LoginSuccessModel({
    required this.error,
    this.workStatus,
  }) : super(error: error);

  final int error;
  final WorkStatus? workStatus;

  factory LoginSuccessModel.fromJson(Map<String, dynamic> json) {
    return LoginSuccessModel(
      error: json['error_code'],
      workStatus: (json['work_status'] != null)
          ? WorkStatus.fromJson(json['work_status'])
          : null,
    );
  }

  @override
  List<Object?> get props => [workStatus, error];
}

class RegisterSuccessModel extends ServerAnswerModel<String> {
  const RegisterSuccessModel({
    required this.error,
    this.errorStatus,
    this.workStatus,
  }) : super(error: error);
  final int error;
  final String? errorStatus;
  final String? workStatus;

  factory RegisterSuccessModel.fromJson(Map<String, dynamic> json) {
    return RegisterSuccessModel(
      error: json['error_code'],
      errorStatus: json['error_status'],
      workStatus: (json['work_status'] != null) ? json['work_status'] : null,
    );
  }

  @override
  List<Object?> get props => [errorStatus, workStatus, error];
}

class WorkStatus {
  const WorkStatus({
    required this.udid,
  });
  final String udid;

  factory WorkStatus.fromJson(Map<String, dynamic> json) {
    return WorkStatus(
      udid: json['udid'],
    );
  }
}
