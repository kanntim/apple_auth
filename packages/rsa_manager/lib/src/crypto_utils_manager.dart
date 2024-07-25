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

  toDer(RSAPublicKey key) {
    return Uint8List.fromList([
      ...CryptoUtils.rsaPublicKeyModulusToBytes(publicKey),
      ...CryptoUtils.rsaPublicKeyExponentToBytes(publicKey)
    ]);
  }

  //to PEM
  String get pemRsaPublicKey {
    final pem = CryptoUtils.encodeRSAPublicKeyToPem(publicKey);
    return base64Encode(pem.codeUnits);
  }

  String signData(String data) {
    final hashedData = CryptoUtils.getHashPlain(
        Uint8List.fromList(data.codeUnits),
        algorithmName: 'SHA-1');
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
