part of 'login_bloc.dart';

enum SubmissionStatus { initial, inProgress, success, failure, canceled }

final class LoginState extends Equatable {
  const LoginState({
    this.status = SubmissionStatus.initial,
    this.udid = '',
    this.login = '',
    this.isHasAppleId = false,
    this.serverAnswer,
  });

  final SubmissionStatus status;
  final String udid;
  final String login;
  final bool isHasAppleId;
  final ServerAnswerModel? serverAnswer;

  LoginState copyWith(
      {SubmissionStatus? status,
      String? udid,
      String? login,
      bool? isHasAppleId,
      ServerAnswerModel? serverAnswer}) {
    return LoginState(
        status: status ?? this.status,
        udid: udid ?? this.udid,
        login: login ?? this.login,
        isHasAppleId: isHasAppleId ?? this.isHasAppleId,
        serverAnswer: serverAnswer ?? this.serverAnswer);
  }

  @override
  get props => [status, udid, login, serverAnswer];
}
