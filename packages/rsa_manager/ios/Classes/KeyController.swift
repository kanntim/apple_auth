
import Foundation
import CommonCrypto
import CryptoKit

class KeyController{

    static func generateKeyPair() -> (privateKey: SecKey?, publicKey: SecKey?) {
        var error: Unmanaged<CFError>?
        let publicKeyAttr: [NSObject: NSObject] = [
                    kSecAttrIsPermanent:true as NSObject,
                    kSecClass: kSecClassKey, // added this value
                    kSecReturnData: kCFBooleanTrue] // added this value
        let privateKeyAttr: [NSObject: NSObject] = [
                    kSecAttrIsPermanent:true as NSObject,
                    kSecClass: kSecClassKey, // added this value
                    kSecReturnData: kCFBooleanTrue] // added this value

        var keyPairAttr = [NSObject: NSObject]()
        keyPairAttr[kSecAttrKeyType] = kSecAttrKeyTypeRSA
        keyPairAttr[kSecAttrKeySizeInBits] = 2048 as NSObject
        keyPairAttr[kSecPublicKeyAttrs] = publicKeyAttr as NSObject
        keyPairAttr[kSecPrivateKeyAttrs] = privateKeyAttr as NSObject

        var publicKey : SecKey?
        var privateKey : SecKey?;

        let statusCode = SecKeyGeneratePair(keyPairAttr as CFDictionary, &publicKey, &privateKey)
        print(publicKey)
        if statusCode == noErr && publicKey != nil && privateKey != nil {
            print("Key pair generated OK")
            var resultPublicKey: AnyObject?
            let statusPublicKey = SecItemCopyMatching(publicKeyAttr as CFDictionary, &resultPublicKey)
            

            if statusPublicKey == noErr {
                if let publicKey = resultPublicKey as? Data {
                    print("Public Key: \((publicKey.base64EncodedString()))")
                }
            }
        } else {
            print("Error generating key pair: \(String(describing: statusCode))")
        }
        
        return (privateKey, publicKey)
    }
    
    static func getStringifyKey(key: SecKey, type: String)-> String?{
        
        let pub = DerCodec.exp_modToPEM(publicKey: key)
        let pemString = "-----BEGIN \(type)-----\r\n\(pub)\r\n-----END  \(type)-----\r\n"
        
        //print("\nResulting PEM: ", pemString)
        return pemString.toBase64()
        
        let publicKeyAttr: [NSObject: NSObject] = [
                    kSecAttrIsPermanent:true as NSObject,
                    kSecClass: kSecClassKey, // added this value
                    kSecReturnData: kCFBooleanTrue] // added this value
        
        var resultPublicKey: AnyObject?
        let statusPublicKey = SecItemCopyMatching(publicKeyAttr as CFDictionary, &resultPublicKey)
     
        if statusPublicKey == noErr {
                if let publicKey = resultPublicKey as? Data {
                    let toDer = derToPem(der: publicKey, type: type)
                    return toDer
                }
            }
        return nil
    }
    
    static func derToPem(der: Data, type: String) -> String {
        let encoded = der.dataByPrependingX509Header().base64EncodedString(options: [.lineLength64Characters, .endLineWithLineFeed])
        
        let pemString = "-----BEGIN \(type)-----\r\n\(encoded)\r\n-----END  \(type)-----\r\n"
        
        //print("\nResulting PEM: ", pemString)
        return pemString.toBase64()
    }
}

extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}

extension NSInteger{
    func encodedOctets() -> [CUnsignedChar] {
            // Short form
            if self < 128 {
                return [CUnsignedChar(self)];
            }
            
            // Long form
            let i = Int(log2(Double(self)) / 8 + 1)
            var len = self
            var result: [CUnsignedChar] = [CUnsignedChar(i + 0x80)]
            
            for _ in 0..<i {
                result.insert(CUnsignedChar(len & 0xFF), at: 1)
                len = len >> 8
            }
            
            return result
        }
}

extension Data{
    func dataByPrependingX509Header() -> Data {
            let result = NSMutableData()
            
            let encodingLength: Int = (self.count + 1).encodedOctets().count
            let OID: [CUnsignedChar] = [0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
                0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00]
            
            var builder: [CUnsignedChar] = []
            
            // ASN.1 SEQUENCE
            builder.append(0x30)
            
            // Overall size, made of OID + bitstring encoding + actual key
            let size = OID.count + 2 + encodingLength + self.count
            let encodedSize = size.encodedOctets()
            builder.append(contentsOf: encodedSize)
            result.append(builder, length: builder.count)
            result.append(OID, length: OID.count)
            builder.removeAll(keepingCapacity: false)
            
            builder.append(0x03)
            builder.append(contentsOf: (self.count + 1).encodedOctets())
            builder.append(0x00)
            result.append(builder, length: builder.count)
            
            // Actual key bytes
            result.append(self)
            
            return result as Data
        }
}
