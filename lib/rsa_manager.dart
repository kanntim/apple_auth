import 'dart:async';
import 'dart:convert';

import 'package:fast_rsa/fast_rsa.dart';

class RsaManagerSingleton{
  late final String publicKey;
  late final String privateKey;

  RsaManagerSingleton() {
    unawaited(generate().then((keyPair) {
      publicKey = keyPair.publicKey;
      privateKey = keyPair.privateKey;
    }));
  }

  static Future<KeyPair> generate()=> RSA.generate(2048);

  Future<String> createHash(String data)async{
    final hash = await RSA.hash(data, Hash.SHA1);
    final signedHash = await RSA.signPKCS1v15(hash, Hash.SHA256, privateKey);
    return RSA.base64(signedHash);
  }
}