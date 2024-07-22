// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:apple_auth/rsa_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/asymmetric/api.dart';

void main() {
  late final RSAGenerator rsaGenerator = RSAGenerator()..init();
  const message = 'Hello World';

  group('RSAGenerator tests', () {
    test('Key generation', () async {
      expect(rsaGenerator.privateKey, isA<RSAPrivateKey>());
      expect(rsaGenerator.publicKey, isA<RSAPublicKey>());
    });

    test(
      'Sign and verify',
      () async {
        final signature = rsaGenerator.createSignature(message);
        expect(signature, isNotEmpty);
        final verified = rsaGenerator.verifySignature(message, signature);
        expect(verified, isTrue);
      },
    );

    test('Verify signature by loadedPubKey', () async {
      final encryptedSignature =
          base64Encode(rsaGenerator.createSignature(message).codeUnits);
      expect(encryptedSignature, isNotEmpty);
      final loadedPublicKey =
          base64.encode(rsaGenerator.stringifyPub().codeUnits);
      final unpackedPublicKey =
          rsaGenerator.loadPublicKeyFromDer(base64Decode(loadedPublicKey));
      final verified = rsaGenerator.verifySignature(message, encryptedSignature,
          loadedPublicKey: unpackedPublicKey);

      expect(verified, true);
    });
  });
}
