//
//  isJWTValid.swift
//
//  Created by Toyota Project Team on 10/13/16.
//
//

open class AuthLibrary {
    
    var keychainService: KeychainService
    
    required public init() {
        keychainService = KeychainService()
    }

    open func isAuthenticated() -> Bool {
        let id_token = keychainService.getToken(TokenType.id_token.rawValue)
        if (!id_token.isEmpty) {
            return isJwtValid(id_token)
        } else {
            return false
        }
    }
    
    open func login(state: String) -> LoginViewController {
        let storyboard = UIStoryboard (name: "Login", bundle: Bundle(for: LoginViewController.self))
        let viewController: LoginViewController = storyboard.instantiateInitialViewController() as! LoginViewController
        viewController.state = state
        return viewController
    }
    
    open func isJwtValid(_ token: String?) -> Bool {
        return true
    }
    
    open func getClaims() -> Claims {
        let id_token = keychainService.getToken(TokenType.id_token.rawValue)
        if (!id_token.isEmpty) {
            let jwt = id_token.components(separatedBy: ".")
            return convertJwtToClaims(claimsString: jwt[1])
        } else {
            return Claims()
        }
    }
    
    open func clearTokens() {
        keychainService.removeTokens()
    }
    
    func convertJwtToClaims(claimsString: String) -> Claims {
        let returnValue = Claims()
        var claims = claimsString
        switch (claims.characters.count % 4) // Pad with trailing '='s
        {
            case 0: break; // No pad chars in this case
            case 1: claims += "==="; break; // Three pad chars
            case 2: claims += "=="; break; // Two pad chars
            case 3: claims += "="; break; // One pad char
            default: print("Illegal base64 string!")
        }
        
        do {
            let parsedData = try JSONSerialization.jsonObject(with: Data(base64Encoded: claims)!, options: .allowFragments) as! [String:Any]
            print(parsedData)
            print(parsedData["given_name"])
            print(parsedData["emails"])
            returnValue.firstName = parsedData["given_name"] as! String
            returnValue.lastName = parsedData["family_name"] as! String
            let emails = parsedData["emails"] as! [String]
            returnValue.email = emails[0]
        } catch let error as NSError {
            print(error)
        }
        
        return returnValue
    }
}
