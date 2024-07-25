import 'package:flutter_test/flutter_test.dart';
import 'package:key_manager/key_manager.dart';
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
  });
}
