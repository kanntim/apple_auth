
import Foundation
import CommonCrypto
import CryptoKit

class KeyController{

    static func generateKeyPair() -> (privateKey: SecKey?, publicKey: SecKey?) {
        var error: Unmanaged<CFError>?
        let parameters: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrIsPermanent as String: true,
            kSecAttrKeySizeInBits as String: 2048,
        ]
        
//        var publicKey: SecKey?
//        var privateKey: SecKey?
        
        let privateKey = SecKeyCreateRandomKey(parameters as CFDictionary, &error)
        let publicKey = SecKeyCopyPublicKey(privateKey!)
        publicKey
        return (privateKey, publicKey)
        
        
//        let status = SecKeyGeneratePair(parameters as CFDictionary, &publicKey, &privateKey)
//        
//        guard status == errSecSuccess, let privateKey = privateKey, let publicKey = publicKey else {
//            return (nil, nil)
//        }
//        
//        return (privateKey,publicKey)
    }
    
    static func getStringifyKey(key: SecKey?, type: String)-> String?{
        print("\nApple key: ", key!)
        
        guard let keyData = SecKeyCopyExternalRepresentation(key!, nil) as Data?
        else {
                    return nil
                }
        print("\nData from Apple key",keyData.base64EncodedString())
//        var derFromPem = keyData.base64EncodedString().replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
//        derFromPem =  derFromPem.replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
//        derFromPem =  derFromPem.replacingOccurrences(of: "\n", with: "")
//        print(derFromPem)
//        let dataDecoded = NSData(base64Encoded: derFromPem, options: [])

        do{
            let keyDerFormat = try convertSecKeyToDerKeyFormat(publicKey: key!)
            print("\nDER format key:\n")
            print(keyDerFormat.base64EncodedString())
            
            let keyPem = derToPem(der: keyData, type: type)
            print("\nKey resulting PEM from DER",keyPem)
            return keyPem.base64EncodedString(options: .lineLength64Characters)
        }catch{
            print(error)
            return nil
        }
    }
    
    static func addDerKeyInfo(rawPublicKey:[UInt8]) -> [UInt8] {
       let DerHdrSubjPubKeyInfo:[UInt8]=[
           /* Ref: RFC 5480 - SubjectPublicKeyInfo's ASN encoded header */
           0x30, 0x59, /* SEQUENCE */
           0x30, 0x13, /* SEQUENCE */
           0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01, /* oid: 1.2.840.10045.2.1   */
           0x06, 0x08, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, 0x07, /* oid: 1.2.840.10045.3.1.7 */
           0x03, 0x42, /* BITSTRING */
           0x00 /* unused number of bits in bitstring, followed by raw public-key bits */]
       let derKeyInfo = DerHdrSubjPubKeyInfo + rawPublicKey
       return derKeyInfo
   }
    
    static func convertbase64StringToByteArray(base64String: String) -> [UInt8] {
        if let nsdata = NSData(base64Encoded: base64String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)  {
            var bytes = [UInt8](repeating: 0, count: nsdata.length)
            nsdata.getBytes(&bytes,length: nsdata.length)
            return bytes
        }
        else
        {
            print("Invalid base64 String")
        }
        return []
    }
    
    static func convertSecKeyToDerKeyFormat(publicKey:SecKey) throws -> Data
    { var error: Unmanaged<CFError>?
        do
        {
            if let externalRepresentationOfPublicKey = SecKeyCopyExternalRepresentation(publicKey,&error)
            {
                let derKeyFormat = externalRepresentationOfPublicKey as Data
                var publicKeyByteArray = convertbase64StringToByteArray(base64String: derKeyFormat.base64EncodedString())
                publicKeyByteArray =  addDerKeyInfo(rawPublicKey: publicKeyByteArray)
                let pubKey = Data(publicKeyByteArray)
                return pubKey
            }
            else
            {
                throw error as! Error
            }
        }
        catch
        {
            throw error
        }
    }

    static func derToPem(der: Data, type: String) -> Data {
        let encoded = der.base64EncodedString(options: .lineLength64Characters)
        let pemString = "-----BEGIN \(type)-----\r\n\(encoded)\r\n-----END  \(type)-----\r\n"
        
        print("\nResulting PEM: ", pemString)
        return der
    }
}

