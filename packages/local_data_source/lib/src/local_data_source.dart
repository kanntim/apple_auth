import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class LocalDataSource {
  late final SharedPreferences _prefs;

  Future<LocalDataSource> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String getString(String key) {
    return _prefs.getString(key) ?? '';
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
