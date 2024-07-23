import 'package:basic_utils/basic_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_manager/key_manager.dart';
import 'package:uuid/v4.dart';

void main() {
  late final CryptoUtilsManager rsaGenerator = CryptoUtilsManager()..init();
  final udid = UuidV4().generate();
  final rnd = UuidV4().generate();
  final message = udid + rnd;

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
  });
}
