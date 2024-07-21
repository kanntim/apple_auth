
import Foundation

class AuthRequest{
    let oper: String
    let signer: Signer
    var udid: String? = UIDevice.current.identifierForVendor?.uuidString
    var rnd: String  = UUID().uuidString
    init(
        oper: String,
        signer:Signer) {
            self.oper=oper
            self.signer=signer
    }
    
    func mackeConcat()->String {
        print("CONCAT: ", udid!+rnd)
        return udid! + rnd
    }
    
    var dictionary: NSDictionary {
        return [
            "opre": oper,
            "udid": udid ?? "",
            "rnd": rnd,
            "signature": signer.signData(mackeConcat()) ?? ""
        ] as NSDictionary
    }
    
    
}


class AuthRegisterRequest: AuthRequest{
    init(signer: Signer){
        super.init(
            oper:"init",
            signer: signer
        )
        
    }
    
    override var dictionary: NSDictionary{
        return [
            "oper": oper,
            "udid": udid ?? "",
            "rnd": rnd,
            "pmk": KeyController.getStringifyKey(key: signer.publicKey, type: "RSA PUBLIC KEY") ?? "" ,
            "signature": signer.signData(mackeConcat()) ?? ""
        ] as NSDictionary
    }
}

class AuthLoginRequest:AuthRequest{
    let email: String?
    let login: String
    init(email: String?, login: String, signer: Signer) {
        self.email = email
        self.login = login
        super.init(oper: "login_apple_id", signer: signer)
    }
    
    override func mackeConcat()->String {
        return udid! + rnd + login
    }
    
    override var dictionary: NSDictionary{
        return [
            "oper": oper,
            "udid": udid ?? "",
            "rnd": rnd,
            "email":email ?? "",
            "login":login,
            "signature": signer.signData(mackeConcat()) ?? ""
        ] as NSDictionary
    }
}
