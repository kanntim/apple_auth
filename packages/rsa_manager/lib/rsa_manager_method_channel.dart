import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'rsa_manager_platform_interface.dart';

/// An implementation of [RsaManagerPlatform] that uses method channels.
class MethodChannelRsaManager extends RsaManagerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('rsa_manager');

  @override
  Future<Map<String, dynamic>?> generateKeys() async {
    try {
      final Map<dynamic, dynamic>? data =
          await methodChannel.invokeMethod('generateKeys');
      return (data as Map).cast<String, dynamic>();
    } on PlatformException catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> makeRegisterRequest(
      {required String login, required String udid, String? email}) async {
    try {
      final Map<dynamic, dynamic>? data = await methodChannel.invokeMethod(
          'makeRegisterRequest',
          {'login': login, 'email': email, 'udid': udid} as Map);
      return (data as Map).cast<String, dynamic>();
    } on PlatformException catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> makeLoginRequest(
      {required String login, required String udid, String? email}) async {
    try {
      final Map<dynamic, dynamic>? data = await methodChannel.invokeMethod(
          'makeLoginRequest', {'login': login, 'email': email, 'udid': udid});
      return (data as Map).cast<String, dynamic>();
    } on PlatformException catch (e) {
      rethrow;
    }
  }
}
