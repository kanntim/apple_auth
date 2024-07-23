import 'package:apple_auth/app.dart';
import 'package:flutter/material.dart';
import 'package:key_manager/key_manager.dart';

void main() async {
  RsaManager().init();
  RSAGenerator().init();
  CryptoUtilsManager().init();
  runApp(const App());
}

/*class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Apple Auth'),
    );
  }
}*/
