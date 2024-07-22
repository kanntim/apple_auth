import 'package:apple_auth/home_page.dart';
import 'package:apple_auth/rsa_generator.dart';
import 'package:flutter/material.dart';

void main() async {
  await RSAGenerator().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
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
}
