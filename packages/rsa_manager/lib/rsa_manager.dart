import 'rsa_manager_platform_interface.dart';
export 'src/rsa_generator.dart';
export 'src/crypto_utils_manager.dart';

class RsaManager {
  static Future<Map<String, dynamic>?> generateKeys() {
    return RsaManagerPlatform.instance.generateKeys();
  }

  static Future<Map<String, dynamic>?> makeRegisterRequest({required String login, required String udid,  String? email}) {
    return RsaManagerPlatform.instance.makeRegisterRequest(login: login, udid: udid, email: email);
  }

  static Future<Map<String, dynamic>?> makeLoginRequest({required String login, required String udid,  String? email}) {
    return RsaManagerPlatform.instance.makeLoginRequest(login: login, udid: udid, email: email);
  }
}
