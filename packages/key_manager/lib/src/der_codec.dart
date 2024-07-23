import 'dart:math';
import 'dart:typed_data';

class DerCodec {
  static bool isDefinedHashType(hashType) {
    final hashTypeMod = hashType & ~0x80;
    // return hashTypeMod > SIGHASH_ALL && hashTypeMod < SIGHASH_SINGLE
    return hashTypeMod > 0x00 && hashTypeMod < 0x04;
  }

  static bool isCanonicalScriptSignature(Uint8List buffer) {
    if (!isDefinedHashType(buffer[buffer.length - 1])) return false;
    return bip66check(buffer.sublist(0, buffer.length - 1));
  }

  static bool bip66check(buffer) {
    if (buffer.length < 8) return false;
    if (buffer.length > 72) return false;
    if (buffer[0] != 0x30) return false;
    if (buffer[1] != buffer.length - 2) return false;
    if (buffer[2] != 0x02) return false;

    var lenR = buffer[3];
    if (lenR == 0) return false;
    if (5 + lenR >= buffer.length) return false;
    if (buffer[4 + lenR] != 0x02) return false;

    var lenS = buffer[5 + lenR];
    if (lenS == 0) return false;
    if ((6 + lenR + lenS) != buffer.length) return false;

    if (buffer[4] & 0x80 != 0) return false;
    if (lenR > 1 && (buffer[4] == 0x00) && buffer[5] & 0x80 == 0) return false;

    if (buffer[lenR + 6] & 0x80 != 0) return false;

    return !(lenS > 1 &&
        (buffer[lenR + 6] == 0x00) &&
        buffer[lenR + 7] & 0x80 == 0);
  }

  static Uint8List bip66encode(r, s) {
    var lenR = r.length;
    var lenS = s.length;
    if (lenR == 0) throw ArgumentError('R length is zero');
    if (lenS == 0) throw ArgumentError('S length is zero');
    if (lenR > 33) throw ArgumentError('R length is too long');
    if (lenS > 33) throw ArgumentError('S length is too long');
    if (r[0] & 0x80 != 0) throw ArgumentError('R value is negative');
    if (s[0] & 0x80 != 0) throw ArgumentError('S value is negative');
    if (lenR > 1 && (r[0] == 0x00) && r[1] & 0x80 == 0) {
      throw ArgumentError('R value excessively padded');
    }
    if (lenS > 1 && (s[0] == 0x00) && s[1] & 0x80 == 0) {
      throw ArgumentError('S value excessively padded');
    }

    var signature = Uint8List(6 + (lenR as int) + (lenS as int));

    // 0x30 [total-length] 0x02 [R-length] [R] 0x02 [S-length] [S]
    signature[0] = 0x30;
    signature[1] = signature.length - 2;
    signature[2] = 0x02;
    signature[3] = r.length;
    signature.setRange(4, 4 + lenR, r);
    signature[4 + lenR] = 0x02;
    signature[5 + lenR] = s.length;
    signature.setRange(6 + lenR, 6 + lenR + lenS, s);
    return signature;
  }

  static Uint8List encodeSignatureToDER(Uint8List signature) {
    if (signature.length != 64)
      throw ArgumentError("Invalid signature ${signature.length} length");
    final r = toDER(signature.sublist(0, 32));
    final s = toDER(signature.sublist(32, 64));
    return bip66encode(r, s);
  }

  static Uint8List toDER(Uint8List x) {
    var i = 0;
    while (x[i] == 0) {
      ++i;
    }
    if (i == x.length) return zero;
    x = x.sublist(i);
    List<int> combine = List.from(zero);
    combine.addAll(x);
    if (x[0] & 0x80 != 0) return Uint8List.fromList(combine);
    return x;
  }

  static final zero = Uint8List.fromList([0]);

  static Uint8List decode(Uint8List bytes) {
    int rLen = bytes[3];
    int sLen = bytes[5 + rLen];

    final derR = bytes.sublist(4, 4 + rLen);
    final derS = bytes.sublist(6 + rLen, 6 + rLen + sLen);

    final r = toBigEndianFromDER(derR, 32);
    final s = toBigEndianFromDER(derS, 32);

    return Uint8List.fromList(r + s);
  }

  /// Convert [bytes] representing an integer into a list of [length] padded with
  /// zeros on the front
  static Uint8List padZeroBigEndian(Uint8List bytes, int length) =>
      Uint8List.fromList(List.filled(max(length - bytes.length, 0), 0) + bytes);

  /// Converts a DER encoded integer ([der]) to a big endian Uint8List with a
  /// given [length].
  static Uint8List toBigEndianFromDER(Uint8List der, int length) =>
      padZeroBigEndian(der.sublist(der[0] == 0 ? 1 : 0), length);

// TODO: This is not network specific
  static final satoshiMax = BigInt.from(21 * 1e14);

  static bool isSatoshi(BigInt value) {
    return !value.isNegative && value <= satoshiMax;
  }

  static bool isUint(int value, int bit) {
    return (value >= 0 && value <= pow(2, bit) - 1);
  }

  static bool isHash160bit(Uint8List value) {
    return value.length == 20;
  }

  static bool isHash256bit(Uint8List value) {
    return value.length == 32;
  }
}

/*class DerCodec {
  // Преобразование DER в PEM
  static String encodeDERToPEM(Uint8List? derBytes) {
    final base64DER = base64Encode(derBytes!);
    final chunks = _chunk(base64DER, 64);
    */ /*final pemString =
        """-----BEGIN PUBLIC KEY-----\r\n$base64DER\r\n-----END PUBLIC KEY-----""";*/ /*
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
}*/
