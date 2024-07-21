import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';


class RSAGenerator{
  // Future<KeyPair> generateRSAKeyPair() async{
  //   final keyPair = await RSA.generate(2048);
  //   return keyPair;
  // }

   Uint8List pemToDer(String pem) {
     final lines = pem.split('\n');
     final base64Data = lines
         .where((line) => !line.startsWith('-----'))
         .join();
     return base64Decode(base64Data);
   }

   signData(String data, String privateKey) {


    // final dataToSign = Uint8List.fromList(utf8.encode(data));
    // final signature = signer.generateSignature(dataToSign);
    //
    // return base64Encode(signature.toString().codeUnits);
  }
}