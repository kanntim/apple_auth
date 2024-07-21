
import Foundation
import CommonCrypto
import CryptoKit

class Signer{
    var privateKey: SecKey
    var publicKey: SecKey
        init(privateKey: SecKey, publicKey: SecKey) {
            self.privateKey = privateKey
            self.publicKey = publicKey
        }
    
     func sha1Hash(_ input: String) -> Data {
        let data = input.data(using: .utf8)!
         let hashed = Insecure.SHA1.hash(data: data)
         let hashedString = hashed.compactMap { String(format: "%02x", $0) }.joined()
         print("SHA1 encrypted: ", hashedString)
         return Data(hashedString.utf8)
    }
    
     func signData(_ input: String) -> String? {
         let hashedData = sha1Hash(input)
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(privateKey, .rsaSignatureMessagePKCS1v15SHA256, hashedData as CFData, &error) else {
            print("Error signing data: \(error!.takeRetainedValue() as Error)")
            return nil
        }
         return (signature as Data).base64EncodedString(options: .lineLength64Characters)
    }
}
