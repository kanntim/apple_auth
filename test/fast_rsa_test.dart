import 'package:flutter_test/flutter_test.dart';
import 'package:key_manager/key_manager.dart';

void main() {
  final rsaManager = RsaManager();

  test('Generate RSA key', () async {
    final publicKey = rsaManager.publicKey;
    print(publicKey);
  });
}
