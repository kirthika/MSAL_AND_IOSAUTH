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
        var returnValue = Claims()
        if (!id_token.isEmpty) {
            let jwt = id_token.components(separatedBy: ".")
            guard let data = Data(base64Encoded: jwt[1]) else {
                return nil
            }
            
            let claims = String(data: data, encoding: .utf8)
            print(claims)
            return returnValue
        } else {
            return returnValue
        }
    }
    
    open func clearTokens() {
        keychainService.removeTokens()
    }
}
