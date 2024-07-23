import 'dart:convert';

import 'package:apple_auth/http_service.dart';
import 'package:apple_auth/request_models.dart';
import 'package:apple_auth/server_answer_model.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:key_manager/key_manager.dart';
import 'package:uuid/uuid.dart';
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
  final rsaManager = RsaManager();
  final rsaGenerator = RSAGenerator();
  final basicUtilManager = CryptoUtilsManager();
  ServerAnswerModel? serverAnswerModel;

  @override
  void initState() {
    basicUtilManager.init();
    super.initState();
  }

  Future _generateRSAKeyPair() async {
    try {
      final Map<dynamic, dynamic>? data =
          await platform.invokeMethod('generateKeys');
      result = data?['udid'];
      print(data?['privateKey']);
    } on PlatformException catch (e) {
      result = 'Error: ${e.message}';
    }
  }

  Future _makeRegisterRequest() async {
    try {
      final Map<dynamic, dynamic>? data =
          await platform.invokeMethod('makeRegisterRequest');
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
      final Map<dynamic, dynamic>? data =
          await platform.invokeMethod('makeLoginRequest');
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
              serverAnswerModel?.workStatus?.udid ??
                  serverAnswerModel?.errorStatus ??
                  '',
            ),
            MaterialButton(
              onPressed: () async {
                final result = await requestFunc3();
                setState(() {
                  serverAnswerModel = result;
                });
              },
              color: Colors.red,
              child: const Text('Generate RSA Key Pair'),
            ),
            //const AppleSignInButton(),
          ],
        ),
      ),
    );
  }

  Future<ServerAnswerModel> requestFunc3() async {
    const udid =
        '933E8F70-D9B6-409D-8A48-1D8113C2D3B6'; //'' //await FlutterUdid.udid;
    final rnd = const UuidV4().generate();
    final concat = udid + rnd;
    final signature = basicUtilManager.signData(concat);
    final publicKey = base64Encode(basicUtilManager.pemRsaPublicKey.codeUnits);

    final request = RegisterRequest(
        udid: udid, rnd: rnd, signature: signature, pmk: publicKey);
    final result =
        await HttpUtil().post('/ios.php', data: jsonEncode(request.toMap()));
    print(ServerAnswerModel.fromJson(result).errorStatus);
    return ServerAnswerModel.fromJson(result);
  }

  Future<ServerAnswerModel> requestFunc() async {
    final udid = '933E8F70-D9B6-409D-8A48-1D8113C2D3B6';
    ; //await FlutterUdid.udid;
    final rnd = const Uuid().v4();
    final concat = udid + rnd;
    final signature = rsaGenerator.createSignature(concat);
    final publicKey = rsaGenerator.stringifyPub();

    final request = RegisterRequest(
        udid: udid, rnd: rnd, signature: signature, pmk: publicKey.toString());
    final result =
        await HttpUtil().post('/ios.php', data: jsonEncode(request.toMap()));
    print(ServerAnswerModel.fromJson(result).errorStatus);
    return ServerAnswerModel.fromJson(result);
  }

  Future<ServerAnswerModel> requestFunc2() async {
    const udid =
        '933E8F70-D9B6-409D-8A48-1D8113C2D3B6'; //'' //await FlutterUdid.udid;
    final rnd = const UuidV4().generate();
    final concat = udid + rnd;
    final signature = await rsaManager.createHash(concat);
    final publicKey = await RSA.base64(rsaManager.publicKey);

    final request = RegisterRequest(
        udid: udid, rnd: rnd, signature: signature, pmk: publicKey.toString());
    final result =
        await HttpUtil().post('/ios.php', data: jsonEncode(request.toMap()));
    print(ServerAnswerModel.fromJson(result).errorStatus);
    return ServerAnswerModel.fromJson(result);
  }
}
