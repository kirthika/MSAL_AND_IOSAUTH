//
//  isJWTValid.swift
//
//  Created by Toyota Project Team on 10/13/16.
//
//

import JWT
import Alamofire

open class AuthLibrary {
    
    var authProps: PListService
    
    required public init() {
        authProps = PListService()
    }

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

    open func getAuthCode() -> String {
        var auth_code = ""
        //let authCodeProps = PListService("authCodeRequest")
        //let request = authProps.getProperty("domain") + "3ca60f43-0cb5-4822-9ca0-1553fc5382c9/" + authProps.getProperty("oauth") + authProps.getProperty("authorize")
        let request = "https://login.microsoftonline.com/3ca60f43-0cb5-4822-9ca0-1553fc5382c9/oauth2/v2.0/authorize"
        print(request)
        Alamofire.request(request,/*authProps.getProperty("domain") + "3ca60f43-0cb5-4822-9ca0-1553fc5382c9/" + authProps.getProperty("oauth") + authProps.getProperty("authorize"),*/
                          method: .get,
                          parameters: ["p": "B2C_1_SignupAndSignin", "client_id": "93406a76-dc2a-4fa9-a900-25f8151762c8", "redirect_uri":"urn%3Aietf%3Awg%3A2.0%3Aoob", "scope":"openid%20offline_access", "state":"currenttempstate", "response_type":"code", "response_mode":"query","prompt":"login"])
            .responseString { auth_code in print("Response String: \(auth_code.result.value)") }
        print(auth_code)
        return auth_code
    }
    
//    open func getAuthAndIdTokens() -> [String] {
//        Alamofire.request(.GET, ")
//        
//        return []
//    }
}
