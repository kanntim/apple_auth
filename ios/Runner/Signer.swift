
import Foundation
import CommonCrypto

class Signer{
    var privateKey: SecKey
    var publicKey: SecKey
        init(privateKey: SecKey, publicKey: SecKey) {
            self.privateKey = privateKey
            self.publicKey = publicKey
        }
    
     
    
     func signData(_ input: String) -> String? {
         let hashedData = input.sha1()
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(privateKey, .rsaSignatureMessagePKCS1v15SHA256, hashedData as CFData, &error) else {
            print("Error signing data: \(error!.takeRetainedValue() as Error)")
            return nil
        }
         return (signature as Data).base64EncodedString()
    }
}

extension String {
    func sha1() -> Data {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        //let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return Data(digest)//hexBytes.joined()
    }
}
