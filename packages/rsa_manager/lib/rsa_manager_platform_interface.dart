import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'rsa_manager_method_channel.dart';

abstract class RsaManagerPlatform extends PlatformInterface {
  /// Constructs a RsaManagerPlatform.
  RsaManagerPlatform() : super(token: _token);

  static final Object _token = Object();

  static RsaManagerPlatform _instance = MethodChannelRsaManager();

  /// The default instance of [RsaManagerPlatform] to use.
  ///
  /// Defaults to [MethodChannelRsaManager].
  static RsaManagerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RsaManagerPlatform] when
  /// they register themselves.
  static set instance(RsaManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<String, dynamic>?> generateKeys() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Map<String, dynamic>?> makeRegisterRequest({required String login, required String udid, String? email}) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Map<String, dynamic>?> makeLoginRequest({required String login, required String udid, String? email}) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
