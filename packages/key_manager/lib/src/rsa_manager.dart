import 'dart:async';
import 'dart:convert';

import 'package:fast_rsa/fast_rsa.dart';

class RsaManager {
  late final String publicKey;
  late final String privateKey;

  static final RsaManager _instance = RsaManager._internal();

  factory RsaManager() {
    return _instance;
  }

  RsaManager._internal();

  String get base64PemPubKey => base64Encode(publicKey.codeUnits);

  init() {
    unawaited(generate().then((keyPair) {
      publicKey = keyPair.publicKey;
      privateKey = keyPair.privateKey;
    }));
  }

  static Future<KeyPair> generate() => RSA.generate(2048);

  Future<String> createHash(String data) async {
    final hash = await RSA.hash(data, Hash.SHA1);
    final signedHash = await RSA.signPKCS1v15(hash, Hash.SHA256, privateKey);
    return RSA.base64(signedHash);
  }
}
