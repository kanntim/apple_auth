import 'dart:convert';
import 'dart:io';

import 'package:apple_auth/apple_sign_in.dart';
import 'package:apple_auth/http_service.dart';
import 'package:apple_auth/request_models.dart';
import 'package:apple_auth/rsa_manager.dart';
import 'package:apple_auth/server_answer_model.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:uuid/v4.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('com.test/generateRSA');
  String result = '';
  final rsaManager = RsaManagerSingleton();
  ServerAnswerModel? serverAnswerModel;

  Future _generateRSAKeyPair() async {
    try {
      final Map<dynamic, dynamic>? data = await platform.invokeMethod('generateKeys');
      result = data?['udid'];
      print(data?['privateKey']);
    } on PlatformException catch (e) {
      result = 'Error: ${e.message}';
    }
  }

  Future _makeRegisterRequest() async {
    try {
      final Map<dynamic, dynamic>? data = await platform.invokeMethod('makeRegisterRequest');
      final result = await HttpUtil().post('/ios.php', data: jsonEncode(data));
      setState(() {
        serverAnswerModel = ServerAnswerModel.fromJson(result);
      });
    } on PlatformException catch (e) {
      result = 'Error: ${e.message}';
    }
    ;
  }

  Future _makeLoginRequest() async {
    try {
      final Map<dynamic, dynamic>? data = await platform.invokeMethod('makeLoginRequest');
      print(data);
    } on PlatformException catch (e) {
      result = 'Error: ${e.message}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              serverAnswerModel?.workStatus?.udid ?? serverAnswerModel?.errorStatus ?? '',
            ),
            MaterialButton(
              onPressed: ()async{
                final udid = await FlutterUdid.udid;
                final rnd = UuidV4().generate();
                final concat = udid + rnd;
                final signature = await rsaManager.createHash(concat);
                final publicKey = await RSA.base64(rsaManager.publicKey);
                final request = RegisterRequest(udid: udid, rnd: rnd, signature: signature, pmk: publicKey);
                final result = await HttpUtil().post('/ios.php', data: jsonEncode(request.toMap()));
                setState(() {
                  serverAnswerModel = ServerAnswerModel.fromJson(result);
                });
              },
              color: Colors.red,
              child: const Text('Generate RSA Key Pair'),
            ),
            const AppleSignInButton(),
          ],
        ),
      ),
    );
  }
}
