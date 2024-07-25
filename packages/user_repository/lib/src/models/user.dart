import 'dart:convert';

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

  Map<String, dynamic> toMap() {
    return {
      'udid': this.udid,
      'login': this.login,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      udid: map['udid'] as String,
      login: map['login'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
