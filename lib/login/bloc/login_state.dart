part of 'login_bloc.dart';

enum SubmissionStatus { initial, inProgress, success, failure, canceled }

final class LoginState extends Equatable {
  const LoginState({
    this.status = SubmissionStatus.initial,
    this.udid = '',
    this.login = '',
    this.isHasAppleId = false,
    this.serverAnswer,
    this.realization = RealizationType.dart,
  });

  final SubmissionStatus status;
  final String udid;
  final String login;
  final bool isHasAppleId;
  final ServerAnswerModel? serverAnswer;
  final RealizationType realization;

  LoginState copyWith({
    SubmissionStatus? status,
    String? udid,
    String? login,
    bool? isHasAppleId,
    ServerAnswerModel? serverAnswer,
    RealizationType? realization,
  }) {
    return LoginState(
      status: status ?? this.status,
      udid: udid ?? this.udid,
      login: login ?? this.login,
      isHasAppleId: isHasAppleId ?? this.isHasAppleId,
      serverAnswer: serverAnswer ?? this.serverAnswer,
      realization: realization ?? this.realization,
    );
  }

  @override
  get props => [status, udid, login, serverAnswer, realization];
}
