//
//  MSALAuthLibrary.swift
//  iOSAuthLibrary
//
//  Copyright © 2017 Pariveda Solutions. All rights reserved.
//

import Foundation
import MSAL

open class MSALAuthLibrary {
    
 /*
     todo:
    1.) let brand: String -> what of these need to stay/go
     let envConfig: String
     let azureProps: PList
     let envProps: PList
     -  policyName = brand.equalsIgnoreCase("Lexus") ? "policySignupOrSigninLexus": "policySignupOrSigninToyota";
        refactor to take in brand and then use the signuporsign policies based on what particular brand it is
     
     2.) introduce logging like the Android application?
     
     3.) Figure out best practices for constants
     
     4.) Application should be instiantiated once, as opposed to calling in every function
     
     5.) getting roles of a user
 
     
     refactoring the location of scopes right now!
 */
  
    let clientId: String
    let tenantName: String
    let SignupOrSigninPolicy: String
    let EditProfilePolicy: String
    var authority: String
    let scopes: [String]
    
    // let kGraphURI: String

    // DO NOT CHANGE - This is the format of OIDC Token and Authorization endpoints for Azure AD B2C.
    lazy var endpoint: String = "https://login.microsoftonline.com/tfp/%@/%@"
    
    required public init(_ clientId: String, _ tenantName: String, _ SignupOrSigninPolicy: String, _ EditProfilePolicy: String, _ scopes: [String]) {
        self.clientId = clientId
        self.SignupOrSigninPolicy = SignupOrSigninPolicy
        self.EditProfilePolicy = EditProfilePolicy
        self.tenantName = tenantName
        self.authority = ""
        self.scopes = scopes // scopes should be defined here
    }
    
    open func login(completion: @escaping (Bool) -> Void){
        print("in login")
        self.authority = String(format: endpoint, tenantName, SignupOrSigninPolicy)
        if let application = try? MSALPublicClientApplication.init(clientId: self.clientId,authority: self.authority) {
            application.acquireToken(forScopes: self.scopes) { (result, error) in
                if  error == nil {
                    let accessToken = (result?.accessToken)!
                    print("first Access token")
                    print(accessToken)
                    completion(true)
                } else {
                    print("error occurred getting token")
                    print("Error info: \(String(describing: error))")
                    completion(false)
                }
            }
        } else {
            print("error instantiating MSAL application")
            completion(false)
        }
    }
    
 /*
    open func renewTokens(completion: @escaping (Bool) -> Void) {
        // todo: test
        // check if current access token or refreshes the token!
        do {
            let application = try MSALPublicClientApplication.init(clientId: self.clientId, authority: self.authority)
            let thisUser = try self.getUserByPolicy(withUsers: application.users(), forPolicy: self.SignupOrSigninPolicy)
            application.acquireTokenSilent(forScopes: self.scopes, user: thisUser){(result, error) in
                if error == nil {
                    // valid token exists w/ refresh
                    completion(true)
                } else if (error! as NSError).code == MSALErrorCode.interactionRequired.rawValue {
                    // requires re sign in to get token
                    application.acquireToken(forScopes: self.scopes, user: thisUser){(result, error) in
                        if error == nil {
                            completion(true)
                        } else {
                            print("Could not acquire new token: \(error ?? "No error informarion" as! Error)")
                            completion(false)                        }
                        }
                } else {
                    print("Could not acquire new token: \(error ?? "No error informarion" as! Error)")
                    completion(false)
                }
            }
        } catch {
            print("error reached")
        }
    }
        
    open func acquireToken() -> String { // return token string for isAuthorized
        // TODO: build out functionality here
      return "token string"
    }
    
    open func signOut(){
        // TODO: test
        do {
            let application = try MSALPublicClientApplication.init(clientId: self.clientId, authority: self.authority)
            let thisUser = try self.getUserByPolicy(withUsers: application.users(), forPolicy: self.SignupOrSigninPolicy)
            try application.remove(thisUser)
        } catch {
            print("error occurred")
        }
    }

    open func isAuthorized(completion: @escaping (Bool) -> Void) {
        // get token from Azure - assume that if you get a token back from Azure it is valid no JWTValid check
        let token: String = acquireToken()
        // no token back: call renew tokens function in this class
        if(token.isEmpty){
            renewTokens(completion: {(success) in
                if(success){
                    completion(true) // should this be success?
                } else {
                    completion(false)
                }
            })
        }
    }
    
    func getUserByPolicy (withUsers: [MSALUser], forPolicy: String) throws -> MSALUser? {
        // todo: test
        // let forPolicy = forPolicy.lowercased() - check to see if this works without this line
        
        for user in withUsers {
            
            if (user.userIdentifier().components(separatedBy: ".")[0].hasSuffix(forPolicy.lowercased())) {
                return user
            }
        }
        return nil
    }
    

}
*/

    // RenewTokens function: Retrieves refresh token from storage and requests a fresh set of tokens
    // from Azure AD B2C
  /*  open func renewTokens(completion: @escaping (Bool) -> Void) {
        let application = try MSALPublicClientApplication.init(clientId: self.clientID, authority: self.authority)
        let thisUser = try self.getUserByPolicy(withUsers: application.users(), forPolicy: self.SignupOrSigninPolicy)
        
        application.acquireTokenSilent(forScopes: kScopes, user: thisUser ) { (result, error) in
            if error == nil {
                self.accessToken = (result?.accessToken)!
                print("Refreshed access Token is")
                print(self.accessToken)
            }  else if (error! as NSError).code == MSALErrorCode.interactionRequired.rawValue {
                // Notice we supply the user here. This ensures we acquire token for the same user
                // as we originally authenticated.
                
                application.acquireToken(forScopes: self.kScopes, user: thisUser) { (result, error) in
                    if error == nil {
                        
                    }if error == nil {
                        self.accessToken = (result?.accessToken)!
                        self.loggingText.text = "Access token is \(self.accessToken)"
                        
                    } else  {
                        self.loggingText.text = "Could not acquire new token: \(error ?? "No error informarion" as! Error)"
                    }
                }
            } else {
                self.loggingText.text = "Could not acquire token: \(error ?? "No error informarion" as! Error)"
            }
        }
        } catch {
        self.loggingText.text = "Unable to create application \(error)"
    }

    */


    

        // check if there's a proper token NSDate *expiresOn could be used
        
        // if no token - acquireTokenSilentAsync
        
        
        /* open func isAuthenticated() -> () {
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
/*

    open func editProfile() {
            
    }
 
 */

/* Can I still leverage the keychain service?
open func getIdTokenClaims() -> [String: Any] {
    let id_token = keychainService.getToken(TokenType.id_token.rawValue)
    return getClaimsFromToken(id_token)
}

open func getAccessTokenClaims() -> [String: Any] {
    let access_token = keychainService.getToken(TokenType.access_token.rawValue)
    return getClaimsFromToken(access_token)
}

open func getClaimsFromToken(_ token: String) -> [String: Any] {
    if (!token.isEmpty) {
        return convertTokenToClaims(token)
    } else {
        return [String: Any]()
    }
}

open func getRoles() -> [String:Any] {
    let userInfo = getIdTokenClaims()
    var obj : [String: Any] = [:]
    
    if (userInfo["extension_IsShopper"] != nil) {
        obj["isShopper"] = true
    } else {
        obj["isShopper"] = false
    }
    if (userInfo["extension_IsBuyer"] != nil) {
        obj["isBuyer"] = true
    } else {
        obj["isBuyer"] = false
    }
    if (userInfo["extension_IsOwner"] != nil) {
        obj["isOwner"] = true
    } else {
        obj["isOwner"] = false
    }
    if (userInfo["extension_IsDriver"] != nil) {
        obj["isDriver"] = true
    } else {
        obj["isDriver"] = false
    }
    
    return obj
}

open func getAccessToken() -> String {
    return keychainService.getToken(TokenType.access_token.rawValue)
}

open func getIdToken() -> String {
    return keychainService.getToken(TokenType.id_token.rawValue)
}

open func clearIdToken() {
    keychainService.removeToken(TokenType.id_token.rawValue)
}

open func clearTokens() {
    keychainService.removeTokens()
}

func convertTokenToClaims(_ token: String) -> [String: Any] {
    let jwt = token.components(separatedBy: ".")
    var claims = jwt[1]
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
        return parsedData
    } catch let error as NSError {
        print(error)
    }
    
    return [String: Any]()
}

*/
