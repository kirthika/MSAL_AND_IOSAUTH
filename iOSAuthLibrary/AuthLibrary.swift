//
//  isJWTValid.swift
//
//  Created by Toyota Project Team on 10/13/16.
//
//

import JWT

open class AuthLibrary {
    
    required public init() {
    }

    open func isAuthenticated() -> Bool {
        let keychainService = KeychainService()
        let id_token = keychainService.getToken(TokenType.id_token.rawValue)
        if (!id_token.isEmpty) {
            return isJwtValid(id_token)
        } else {
            return false
        }
    }
    
    open func login(state: String) -> LoginViewController {
        let storyboard = UIStoryboard (
            name: "Login", bundle: Bundle(for: LoginViewController.self)
        )
        let viewController: LoginViewController = storyboard.instantiateInitialViewController() as! LoginViewController
        viewController.state = state
        return viewController
    }
    
    open func isJwtValid(_ token: String) -> Bool {
        //let algorithmName = "RS256"
        if (token == nil) {return false}
        let claims = JWT.decodeMessage(token).options(true)
        if ((claims?.decode) != nil) {
            print(claims?.decode)
            return true
        }
        else {
            return false
        }
    }
}
