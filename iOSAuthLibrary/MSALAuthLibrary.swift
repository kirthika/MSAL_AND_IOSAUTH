//
//  MSALAuthLibrary.swift
//  iOSAuthLibrary
//
//  Created by Katie Quinn on 7/2/17.
//  Copyright © 2017 Pariveda Solutions. All rights reserved.
//

import Foundation
import MSAL

open class MSALAuthLibrary {
  
    let clientId: String
    let tenantName: String
    let SignupOrSigninPolicy: String
    let EditProfilePolicy: String

    // let kGraphURI: String
    // let kScopes: [String]
    
    // DO NOT CHANGE - This is the format of OIDC Token and Authorization endpoints for Azure AD B2C.
    lazy var endpoint: String = "https://login.microsoftonline.com/tfp/%@/%@"
    
    required public init(_ clientId: String, _ tenantName: String, _ SignupOrSigninPolicy: String, _ EditProfilePolicy: String) {
        self.clientId = clientId
        self.SignupOrSigninPolicy = SignupOrSigninPolicy
        self.EditProfilePolicy = EditProfilePolicy
        self.tenantName = tenantName
    }
    
    open func login(_ kScopes: [String]) -> String {
        let authority = String(format: endpoint, tenantName, SignupOrSigninPolicy)
        var string = ""
        let storyboard = UIStoryboard (name: "Login", bundle: Bundle(for: LoginViewController.self))
        let viewController: LoginViewController = storyboard.instantiateInitialViewController() as! LoginViewController
        viewController.kScopes = kScopes
        viewController.authority = authority
        viewController.clientId = clientId
        return viewController
 
    /*    do {
            let myApplication = try MSALPublicClientApplication.init(clientId: clientId,authority: authority)
            print(myApplication)
            myApplication.acquireToken(forScopes: kScopes) { (result, error) in
                if  error == nil {
                    let accessToken = (result?.accessToken)!
                    print("first Access token")
                    print(accessToken)
                    string = "access token"
                } else {
                    print("error occurred getting token")
                    print("Error info: \(String(describing: error))")
                    string = "error getting token"
                }
            }
        } catch {
                print("Error info: \(error)")
                string = "another error"
        }
        return string;*/
    }
    /*
    open func isAuthenticated(){
    
    }
    
    open func login(){
        let application = try MSALPublicClientApplication.init(clientId: kClientID, authority: kAuthority)
        application.acquireToken(forScopes: kScopes) { (result, error) in
            if  error == nil {
                self.accessToken = (result?.accessToken)!
                print(self.accessToken)
                
                
            } else {
                //self.loggingText.text = "Could not acquire token: \(error ?? "No error informarion" as! Error)"
            }
    
    }
    
    open func refreshTokens(){
        
    }
        
    open func editProfile() {
            
    }
        

        open func signOut() {
            /**
             
             Initialize a MSALPublicClientApplication with a given clientID and authority
             
             - clientId:     The clientID of your application, you should get this from the app portal.
             - authority:    A URL indicating a directory that MSAL can use to obtain tokens. In Azure B2C
             it is of the form `https://<instance/tfp/<tenant>/<policy>`, where `<instance>` is the
             directory host (e.g. https://login.microsoftonline.com), `<tenant>` is a
             identifier within the directory itself (e.g. a domain associated to the
             tenant, such as contoso.onmicrosoft.com), and `<policy>` is the policy you wish to
             use for the current user flow.
             - error:       The error that occurred creating the application object, if any, if you're
             not interested in the specific error pass in nil.
             */
            
            let application = try MSALPublicClientApplication.init(clientId: kClientID, authority: kAuthority)
            
            /**
             Removes all tokens from the cache for this application for the provided user
             
             - user:    The user to remove from the cache
             */
            
            let thisUser = try self.getUserByPolicy(withUsers: application.users(), forPolicy: kSignupOrSigninPolicy)
            
            try application.remove(thisUser)
        }
    
        func getUserByPolicy (withUsers: [MSALUser], forPolicy: String) throws -> MSALUser? {
            
            let forPolicy2 = forPolicy.lowercased() // doesn't fix it
            
            for user in withUsers {
                
                if (user.userIdentifier().components(separatedBy: ".")[0].hasSuffix(forPolicy2)) {
                    return user
                }
            }
            return nil
        }
 */
}
