import Flutter
import UIKit
import CommonCrypto

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      let controller : FlutterViewController = window.rootViewController as! FlutterViewController
      setupMethodChannel(with: controller.registrar(forPlugin: "com.test.generateRSA")!)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

func setupMethodChannel(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.test/generateRSA", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { (call, result) in
        if call.method == "generateKeys" {
            let keys = KeyController.generateKeyPair()
            let publicKey = KeyController.getStringifyKey(key:keys.privateKey!, type: "PUBLIC KEY")
            result([
                "privateKey": (SecKeyCopyExternalRepresentation(keys.privateKey!, nil)! as Data).base64EncodedString(),
                "publicKey": publicKey,
                "udid": UIDevice.current.identifierForVendor?.uuidString
            ])
        
        } else if(call.method == "makeRegisterRequest"){
            let keys = KeyController.generateKeyPair()
            let signer: Signer
            if let privateKey = keys.privateKey, let publicKey = keys.publicKey {
                signer = Signer(privateKey: privateKey , publicKey: publicKey )
                result(AuthRegisterRequest(signer: signer).dictionary)
            }
        }
        else if(call.method == "makeLoginRequest"){
            if let args = call.arguments as? Dictionary<String, Any>,
                let email = args["email"] as? String?,
                let login = args["login"] as? String {
                
                let keys = KeyController.generateKeyPair()
                let signer: Signer
                if let privateKey = keys.privateKey, let publicKey = keys.publicKey {
                    signer = Signer(privateKey: privateKey , publicKey: publicKey )
                    
                    result(AuthLoginRequest(email: email, login:login, signer: signer).dictionary)
                }
                
                
              } else {
                result(FlutterError.init(code: "bad args", message: nil, details: nil))
              }
            
        }else {
            result(FlutterMethodNotImplemented)
        }
    }
}

func makeRigisterRequest(signer:Signer)->NSDictionary{
    return AuthRegisterRequest(signer: signer).dictionary
}

func makeLoginRequest(email:String?, login:String, signer:Signer )->NSDictionary{
    return AuthLoginRequest(email: email, login: login, signer: signer).dictionary
}
