import Foundation

class DerCodec{
    private static func getExponentAndModulus(publicKey: SecKey)->(Data, Data){
        var error: Unmanaged<CFError>?
        let keyData = SecKeyCopyExternalRepresentation(publicKey, &error)
        var publicKeyBytes = keyData! as Data
        publicKeyBytes.removeSubrange(Range(NSRange(location: 0, length: 9))!)
        let mod = publicKeyBytes.subdata(in: Range(NSRange.init(location: 0, length: 256))!)
        let exp = publicKeyBytes.subdata(in: Range(NSRange.init(location: publicKeyBytes.count - 3, length: 3))!)
        //this n and e bytes can be expressed in HexaDecimal format or base64 format
        return (exp,mod)
    }
    
    static func exp_modToPEM(publicKey: SecKey)->String{
        var (exp, mod) = getExponentAndModulus(publicKey: publicKey)
        return RSAConverter.pemFrom(mod_b64: mod.base64EncodedString(), exp_b64: exp.base64EncodedString())!
    }
}
