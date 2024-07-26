import 'package:apple_auth/app.dart';
import 'package:apple_auth/core/srvices/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:rsa_manager/rsa_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  RSAGenerator().init();
  CryptoUtilsManager().init();
  await InjectionContainer.init();
  runApp(const App());
}

