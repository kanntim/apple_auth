import 'dart:convert';

import 'package:apple_auth/crypto_utils_manager.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final CryptoUtilsManager rsaGenerator = CryptoUtilsManager()..init();
  const message = 'Hello World';

  group('RSAGenerator tests', () {
    test('Key generation', () async {
      expect(rsaGenerator.privateKey, isA<RSAPrivateKey>());
      expect(rsaGenerator.publicKey, isA<RSAPublicKey>());
    });

    test(
      'Sign and verify',
      () async {
        final signature = rsaGenerator.signData(message);
        expect(signature, isNotEmpty);
        final verified = rsaGenerator.verifySignature(message, signature);
        expect(verified, isTrue);
      },
    );

    test('Verify signature by loadedPubKey', () async {
      final encryptedSignature =
          base64Encode(rsaGenerator.signData(message).codeUnits);
      expect(encryptedSignature, isNotEmpty);
      final sandedPublicKey =
          base64Encode(rsaGenerator.pemRsaPublicKey.codeUnits);
      print(base64Decode(sandedPublicKey));
      final unpackedPublicKey = rsaGenerator
          .loadPublicKeyFromPem(utf8.decode(base64Decode(sandedPublicKey)));
      expect(sandedPublicKey, rsaGenerator.pemRsaPublicKey);

      final verified = rsaGenerator.verifySignature(
          message, utf8.decode(base64Decode(encryptedSignature)),
          loadedPublicKey: unpackedPublicKey);

      expect(verified, true);
    });
  });
}
