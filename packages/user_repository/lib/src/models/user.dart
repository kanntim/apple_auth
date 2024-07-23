import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.udid,
    required this.login,
  });

  final String udid;
  final String login;

  @override
  List<Object> get props => [udid, login];

  static const empty = User(login: '-', udid: '-');
}
