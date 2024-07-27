import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageRepo{

  final _secureStorage = const FlutterSecureStorage();

  Future<String?> getUserKeyById(String userId) async {
    return  get('${userId}_key');
  }

  Future<void> setUserKeyById(String userId, String key) async {
    return set('${userId}_key', key);
  }

  Future<String?> get(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> set(String key, String value) async {
    return _secureStorage.write(key: key, value: value);
  }

  Future<void> delete(String key) async {
    return _secureStorage.delete(key: key);
  }

  Future<Map<String, String>> getAll() async {
    Map<String, String> values = await _secureStorage.readAll();
    return values;
  }

  Future<void> clear() async {
    return _secureStorage.deleteAll();
  }

}
