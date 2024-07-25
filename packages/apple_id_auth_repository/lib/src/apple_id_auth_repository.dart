import 'dart:async';

import 'package:apple_id_auth_repository/src/models/apple_credential_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleIdAuthRepository {
  Future<AppleCredentialModel> getAppleIDCredential() async {
    try {
      final result = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.test.apple-auth-android',
          redirectUri: Uri.parse('your_redirect_uri'),
        ),
      );
      final authorizationCode = result.authorizationCode;
      final identityToken = result.identityToken;


      return AppleCredentialModel(
          email: result.email, userIdentifier: result.userIdentifier!);
    } catch (error) {
      rethrow;
    }
  }
}
