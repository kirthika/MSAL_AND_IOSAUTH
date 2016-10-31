//
//  isJWTValid.swift
//
//  Created by Toyota Project Team on 10/13/16.
//
//

import JWT

open class AuthLibrary {
    
    required public init() { }

    open func isAuthenticated() -> Bool {
        print("isAuthenticated func")
        let keychainService = KeychainService()
        print("before get token")
        let id_token = keychainService.getToken()
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
    
    open func isJwtValid(_ token: String?) -> Bool {
        return true
    }
    
    open func clearTokens() {
        let keychainService = KeychainService()
        keychainService.removeTokens()
    }
}
