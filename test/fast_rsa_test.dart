import 'package:apple_auth/rsa_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final rsaManager = RsaManager();

  test('Generate RSA key', () async {
    final publicKey = rsaManager.publicKey;
    print(publicKey);
  });
}
