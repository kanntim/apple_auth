import 'dart:convert';
import 'dart:math';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/digests/sha1.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/signers/rsa_signer.dart';

import 'der_codec.dart';

class RSAGenerator {
  late final RSAPublicKey publicKey;
  late final RSAPrivateKey privateKey;

  static final RSAGenerator _instance = RSAGenerator._internal();

  factory RSAGenerator() {
    return _instance;
  }

  RSAGenerator._internal();

  Future init() async {
    final keyPair = generateRSAKeyPair();
    privateKey = (keyPair.privateKey as RSAPrivateKey);
    publicKey = (keyPair.publicKey as RSAPublicKey);
  }

  String stringifyPub() {
    final derPublic = encodePublicKeyToDER(publicKey);
    return base64Encode(DerCodec.encodeSignatureToDER(derPublic!));
  }

  // Генерация пары ключей RSA
  AsymmetricKeyPair<PublicKey, PrivateKey> generateRSAKeyPair() {
    final secureRandom = getSecureRandom();
    var rsaParams =
        RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 5); //5-64?
    var params = ParametersWithRandom(rsaParams, secureRandom);
    final keyGen = RSAKeyGenerator()..init(params);
    return keyGen.generateKeyPair();
  }

  String base64PemPubKey() {
    final derData = encodePublicKeyToDER(publicKey)!;
    var dataBase64 = base64.encode(derData);
    var chunks = StringUtils.chunk(dataBase64, 64);

    return '$BEGIN_PUBLIC_KEY\n${chunks.join('\n')}\n$END_PUBLIC_KEY';
  }

  // Кодирование публичного ключа в DER
  Uint8List? encodePublicKeyToDER(RSAPublicKey publicKey) {
    // Создаем последовательность для алгоритма
    var algorithmSeq = ASN1Sequence();
    var paramsAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
    algorithmSeq.add(ASN1ObjectIdentifier.fromName('rsaEncryption'));
    algorithmSeq.add(paramsAsn1Obj);

    // Создаем последовательность для публичного ключа
    var publicKeySeq = ASN1Sequence();
    publicKeySeq.add(ASN1Integer(publicKey.modulus));
    publicKeySeq.add(ASN1Integer(publicKey.exponent));

    // Кодируем ключ в DER формат
    var publicKeySeqBitString =
        ASN1BitString(stringValues: Uint8List.fromList(publicKeySeq.encode()));

    // Создаем последовательность для SubjectPublicKeyInfo
    var topLevelSeq = ASN1Sequence();
    topLevelSeq.add(algorithmSeq);
    topLevelSeq.add(publicKeySeqBitString);
    return topLevelSeq.encode();
  }

  SecureRandom getSecureRandom() {
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  String createSignature(String input) {
    // Хэшируем входную строку с помощью SHA1
    final sha1Digest = SHA1Digest().process(utf8.encode(input));
    // Подписываем хэш с помощью приватного ключа
    final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    final signature = signer.generateSignature(sha1Digest);

    return base64Encode(signature.bytes);
  }

  bool verifySignature(String message, String signature,
      {RSAPublicKey? loadedPublicKey}) {
    final verifier = RSASigner(SHA256Digest(), '0609608648016503040201');
    verifier.init(
        false, PublicKeyParameter<RSAPublicKey>(loadedPublicKey ?? publicKey));
    final unhashedMessage = SHA1Digest().process(utf8.encode(message));
    final rsaSignature = RSASignature(base64Decode(signature));
    return verifier.verifySignature(unhashedMessage, rsaSignature);
  }

  String decryptMessage(String base64EncryptedData) {
    final encryptedData = base64Decode(base64EncryptedData);
    final decryptor = RSAEngine()
      ..init(false, PublicKeyParameter<RSAPublicKey>(publicKey));
    final decryptedData = _processInBlocks(decryptor, encryptedData);
    final unhashedMessage = SHA1Digest().process(decryptedData);
    print(unhashedMessage);
    return utf8.decode(unhashedMessage, allowMalformed: true);
  }

  Uint8List _processInBlocks(AsymmetricBlockCipher engine, Uint8List input) {
    final output = <int>[];
    final blockSize = engine.inputBlockSize;

    for (var i = 0; i < input.length; i += blockSize) {
      final chunkSize =
          (i + blockSize > input.length) ? input.length - i : blockSize;
      final chunk = input.sublist(i, i + chunkSize);
      output.addAll(engine.process(chunk));
    }

    return Uint8List.fromList(output);
  }

  RSAPublicKey loadPublicKeyFromDer(Uint8List der) {
    final asn1Parser = ASN1Parser(der);
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    final algorithmSeq = topLevelSeq.elements?[0] as ASN1Sequence;
    final publicKeyData = topLevelSeq.elements?[1] as ASN1BitString;

    // Обработка RSA публичного ключа
    final rsaKeySeq =
        ASN1Parser(publicKeyData.valueBytes).nextObject() as ASN1Sequence;
    final modulus = rsaKeySeq.elements?[0] as ASN1Integer;
    final exponent = rsaKeySeq.elements?[1] as ASN1Integer;

    return RSAPublicKey(modulus.integer!, exponent.integer!);
  }

  BigInt bigIntFromBytes(Uint8List bytes) {
    return BigInt.parse(HEX.encode(bytes), radix: 16);
  }

  static const BEGIN_PUBLIC_KEY = '-----BEGIN PUBLIC KEY-----';
  static const END_PUBLIC_KEY = '-----END PUBLIC KEY-----';
}
