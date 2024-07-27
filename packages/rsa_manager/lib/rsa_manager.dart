import 'package:flutter_udid/flutter_udid.dart';
import 'package:rsa_manager/rsa_manager.dart';
import 'package:uuid/v4.dart';

import 'rsa_manager_platform_interface.dart';
export 'src/rsa_generator.dart';
export 'src/crypto_utils_manager.dart';

class RsaManager {

  static init()async{
    await RSAGenerator().init();
    await CryptoUtilsManager().init();
  }
  static Future<Map<String, dynamic>?> generateKeys(bool native) {
    return RsaManagerPlatform.instance.generateKeys();
  }

  String getPrivateKey() {
    return CryptoUtilsManager().pemRsaPrivateKey;
  }

  static Future<Map<String, dynamic>?> makeRegisterRequest(
      {required String login, String? email, isNative = false}) async {
    if (isNative) {
      final String udid = await FlutterUdid.udid;
      return await RsaManagerPlatform.instance
          .makeRegisterRequest(login: login, udid: udid, email: email);
    } else {

      final String udid = await FlutterUdid.udid;
      final String rnd = const UuidV4().generate().toLowerCase();
      final String concat = udid + rnd;
      final String signature = CryptoUtilsManager().signData(concat);
      final String publicKey = CryptoUtilsManager().pemRsaPublicKey;
      return {
        'login': login,
        'udid': udid,
        'email': email,
        'signature': signature,
        'pmk': publicKey,
        'rnd': rnd,
      };
    }
  }

  static Future<Map<String, dynamic>?> makeLoginRequest(
      {required String? privateKey, required String login, String? email, isNative = false}) async {
    if (isNative) {
      final String udid = await FlutterUdid.udid;
      return RsaManagerPlatform.instance
          .makeLoginRequest(login: login, udid: udid, email: email);
    } else {
      if (privateKey!=null){
        CryptoUtilsManager().setPrivateFromPem(privateKey);
      }
      final String udid = await FlutterUdid.udid;
      final String rnd = const UuidV4().generate().toLowerCase();
      final String concat = udid + rnd;
      final String signature = CryptoUtilsManager().signData(concat);
      final String publicKey = CryptoUtilsManager().pemRsaPublicKey;

      return {
        'login': login,
        'udid': udid,
        'email': email,
        'signature': signature,
        'pmk': publicKey,
        'rnd': rnd,
      };
    }
  }
}
