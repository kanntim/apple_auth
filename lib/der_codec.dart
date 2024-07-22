import 'dart:convert';
import 'dart:typed_data';

class DerCodec {
  // Преобразование DER в PEM
  static String encodeDERToPEM(Uint8List? derBytes) {
    final base64DER = base64Encode(derBytes!);
    final chunks = _chunk(base64DER, 64);
    /*final pemString =
        """-----BEGIN PUBLIC KEY-----\r\n$base64DER\r\n-----END PUBLIC KEY-----""";*/
    final pemString =
        '-----BEGIN PUBLIC KEY-----\n${chunks.join('\n')}\n-----END PUBLIC KEY-----';
    return pemString;
  }

// Разделение строки на части
  static List<String> _chunk(String str, int size) {
    List<String> chunks = [];
    for (var i = 0; i < str.length; i += size) {
      chunks
          .add(str.substring(i, i + size > str.length ? str.length : i + size));
    }
    return chunks;
  }

  static Uint8List pemToDer(String pem) {
    final regex =
        RegExp(r'-----BEGIN PUBLIC KEY-----\n(.+?)\n-----END PUBLIC KEY-----');
    final matches = regex.firstMatch(pem);
    if (matches != null) {
      final base64String = matches.group(1);
      return base64.decode(base64String!);
    }
    throw ArgumentError('Invalid PEM format');
  }
}
