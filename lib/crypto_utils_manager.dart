import 'dart:convert';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';

class CryptoUtilsManager {
  late final RSAPublicKey publicKey;
  late final RSAPrivateKey privateKey;

  static final CryptoUtilsManager _instance = CryptoUtilsManager._internal();

  factory CryptoUtilsManager() {
    return _instance;
  }

  CryptoUtilsManager._internal();

  Future init() async {
    final AsymmetricKeyPair keyPair = CryptoUtils.generateRSAKeyPair();
    privateKey = (keyPair.privateKey as RSAPrivateKey);
    publicKey = (keyPair.publicKey as RSAPublicKey);
  }

  // to DER
  Uint8List get derRsaPublicKey => Uint8List.fromList([
        ...CryptoUtils.rsaPublicKeyModulusToBytes(publicKey),
        ...CryptoUtils.rsaPublicKeyExponentToBytes(publicKey)
      ]);

  //to PEM
  String get pemRsaPublicKey {
    final der = CryptoUtils.encodeRSAPublicKeyToPemPkcs1(publicKey);
    final pem = encodeDERToPEM(utf8.encode(der));
    return der; //base64Encode(utf8.encode(pem));
  }

  static String encodeDERToPEM(Uint8List? derBytes) {
    final base64DER = base64Encode(derBytes!);
    final chunks = _chunk(base64DER, 64);
    final pemString =
        '-----BEGIN PUBLIC KEY-----\n${chunks.join('\n')}\n-----END PUBLIC KEY-----';
    return pemString;
  }

  static List<String> _chunk(String str, int size) {
    List<String> chunks = [];
    for (var i = 0; i < str.length; i += size) {
      chunks
          .add(str.substring(i, i + size > str.length ? str.length : i + size));
    }
    return chunks;
  }

  String signData(String data) {
    final hashedData =
        CryptoUtils.getHashPlain(utf8.encode(data), algorithmName: 'SHA-1');
    final signature = CryptoUtils.rsaSign(privateKey, hashedData,
        algorithmName: 'SHA-256/RSA');
    return base64Encode(signature);
  }

  bool verifySignature(String message, String signature,
      {RSAPublicKey? loadedPublicKey}) {
    if (loadedPublicKey != null) {
      assert(loadedPublicKey == publicKey);
    }
    final hashedData =
        CryptoUtils.getHashPlain(utf8.encode(message), algorithmName: 'SHA-1');
    return CryptoUtils.rsaVerify(
      loadedPublicKey ?? publicKey,
      hashedData,
      base64Decode(signature),
      algorithm: 'SHA-256/RSA',
    );
  }

  RSAPublicKey loadPublicKeyFromPem(String pem) {
    return CryptoUtils.rsaPublicKeyFromPemPkcs1(pem);
  }
}
