import 'package:apple_auth/apple_id_auth.dart';
import 'package:apple_auth/rsa_generator.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInButton extends StatelessWidget {
  const AppleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: SignInWithAppleButton(
        onPressed: () async {
          // final pair = await RSAGenerator().generateRSAKeyPair();
          // print(pair.publicKey);
          //final credential = await AppleIdAuth.getAppleIDCredential();

        },
      ),
    );
  }
}
