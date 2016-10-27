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
        return false;
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
