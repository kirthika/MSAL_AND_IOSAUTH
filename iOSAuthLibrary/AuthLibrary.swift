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
        let returnValue = Claims()
        if (!id_token.isEmpty) {
            let jwt = id_token.components(separatedBy: ".")
            let claims = convertToString(claimsString: jwt[1])
            returnValue.firstName = claims!["given_name"] as! String
            returnValue.lastName = claims!["family_name"] as! String
            returnValue.email = claims!["emails"]?[0] as! String
            return returnValue
        } else {
            return returnValue
        }
    }
    
    open func clearTokens() {
        keychainService.removeTokens()
    }
    
    func convertToString(claimsString: String) -> [String:AnyObject]? {
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
            return try JSONSerialization.jsonObject(with: Data(base64Encoded: claims)!, options: []) as? [String:AnyObject]
        } catch let error {
            print(error)
            return nil
        }
    }
}
