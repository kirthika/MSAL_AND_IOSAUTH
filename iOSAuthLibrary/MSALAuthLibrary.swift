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
    
    open func login(_ kScopes: [String]) -> () {
        do {
            var authority = String(format: self.endpoint, self.tenantName, self.SignupOrSigninPolicy)
            print("in login")
            /*let myApplication = try MSALPublicClientApplication.init(clientId: self.clientId,authority: authority)
            print(myApplication)
            myApplication.acquireToken(forScopes: kScopes) { (result, error) in
                print("in callback")
                print(kScopes)
                if  error == nil {
                    let accessToken = (result?.accessToken)!
                    print("first Access token")
                    print(accessToken)
                } else {
                    print("error occurred getting token")
                    print("Error info: \(String(describing: error))")
                    print("error getting token")
                }
            }*/
        } catch {
            print("Error info: \(error)")
            print("another error")
        }
    }
    
    open func isAuthenticated() -> () {
        /*
         / @property BOOL validateAuthority -> this seems to be just preventing from malicious things
         it always is true -> how do you check if the token is valid?
         
         ! The authority the application will use to obtain tokens
        @property (readonly) NSURL *authority;
         
         @property (readonly) NSDate *expiresOn; - this is from the MSALuser/result class
         */
        /*
        let id_token = keychainService.getToken(TokenType.id_token.rawValue)
        if (!id_token.isEmpty) {
            if (!isJwtValid(id_token)) {    // An Id Token exists, but it's not valid
                renewTokens(completion: { (success) in
                    if (success) {
                        completion(success)
                    } else {
                        completion(false)
                    }
                })
            } else {
                completion(true)    // A saved, valid token exists
            }
        } else {    // No ID Token exists
            renewTokens(completion: { (success) in
                if (success) {
                    completion(success)
                } else {
                    completion(false)
                }
            })
        }*/
    }
        /*
 I think the view controller can be replaced w/ just the application functionality though I am not sure why it's not working
         
 */
 
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
