import Flutter
import UIKit

public class RsaManagerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "rsa_manager", binaryMessenger: registrar.messenger())
    let instance = RsaManagerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
            case "getPlatformVersion":
                result("iOS " + UIDevice.current.systemVersion)
            case "generateKeys":
                self.generateRsaKeyPair(result: result)
            case "makeRegisterRequest":
        self.makeRegisterRequest(result: result, call:call)
            case "makeLoginRequest":
        self.makeLoginRequest(result: result, call:call)
            default:
                result(FlutterMethodNotImplemented)
            }
  }

  private func generateRsaKeyPair(result: @escaping FlutterResult) {
  let keys = KeyController.generateKeyPair()

  let publicKey = KeyController.getStringifyKey(key:keys.privateKey!, type: "PUBLIC KEY")
              result([
                  "privateKey": (SecKeyCopyExternalRepresentation(keys.privateKey!, nil)! as Data).base64EncodedString(),
                  "publicKey": publicKey,
                  "udid": UIDevice.current.identifierForVendor?.uuidString
              ])
  }

    private func makeRegisterRequest(result: @escaping FlutterResult, call: FlutterMethodCall) {
        let keys = KeyController.generateKeyPair()
        let signer: Signer
        if let privateKey = keys.privateKey, let publicKey = keys.publicKey {
            signer = Signer(privateKey: privateKey , publicKey: publicKey )
            result(AuthRegisterRequest(signer: signer).dictionary)
        }
      
  }

    private func makeLoginRequest(result: @escaping FlutterResult, call: FlutterMethodCall) {
        if let args = call.arguments as? Dictionary<String, Any>,
           let email = args["email"] as? String?,
           let login = args["login"] as? String,
           let udId = args["udid"] as? String?  {

            let keys = KeyController.generateKeyPair()
            let signer: Signer
            if let privateKey = keys.privateKey, let publicKey = keys.publicKey {
                signer = Signer(privateKey: privateKey , publicKey: publicKey )
                result(AuthLoginRequest(email: email, login:login, signer: signer).dictionary)
            }
        } else {
            result(FlutterError.init(code: "bad args in makeLoginRequest", message: nil, details: nil))
        }
    }
    
    private func makeRigisterRequest(signer:Signer)->NSDictionary{
        return AuthRegisterRequest(signer: signer).dictionary
    }

    private func makeLoginRequest(email:String?, login:String, signer:Signer )->NSDictionary{
        return AuthLoginRequest(email: email, login: login, signer: signer).dictionary
    }

}
