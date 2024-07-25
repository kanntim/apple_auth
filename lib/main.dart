import 'package:apple_auth/app.dart';
import 'package:apple_auth/core/srvices/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:key_manager/key_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  RSAGenerator().init();
  CryptoUtilsManager().init();
  await InjectionContainer.init();
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
