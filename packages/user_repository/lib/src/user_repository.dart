import 'dart:async';

import 'package:local_data_source/local_data_source.dart';
import 'package:user_repository/src/models/models.dart';

class UserRepository {
  UserRepository(this._source);
  final LocalDataSource _source;
  User? _user;

  setUser({required String userId, required String login}) {
    _user = User(udid: userId, login: login);
    _source.setString(userId, _user!.toJson());
  }

  Future<User?> getUser(String userId) async {
    final userData = await _source.getString(userId);
    if (userData.isNotEmpty) {
      _user = User.fromJson(userData);
    }
    if (_user != null) return _user;
    return null;
  }

  Future<void> deleteAll() async {
    _user = null;
    await _source.clear();
  }
}
