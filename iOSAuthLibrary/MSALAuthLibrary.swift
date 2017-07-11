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
     
     3.) test
     
     4.) Application should be instiantiated once, as opposed to calling in every function
     
     5.) change dictionary to a closure
     
*/
  
    let clientId: String
    let tenantName: String
    let SignupOrSigninPolicy: String
    let EditProfilePolicy: String
    var authority: String
    let scopes: [String]
    private var token: [String : String]
    
    //self.application = application: we should only instantiate this once!
    
    // let kGraphURI: String

    // DO NOT CHANGE - This is the format of OIDC Token and Authorization endpoints for Azure AD B2C.
    lazy var endpoint: String = "https://login.microsoftonline.com/tfp/%@/%@"
    
    required public init(_ clientId: String, _ tenantName: String, _ SignupOrSigninPolicy: String, _ EditProfilePolicy: String, _ scopes: [String]) {
        self.clientId = clientId
        self.SignupOrSigninPolicy = SignupOrSigninPolicy
        self.EditProfilePolicy = EditProfilePolicy
        self.tenantName = tenantName
        self.scopes = scopes
        self.authority = ""
        self.token = [:]
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
                    print("id token")
                    print(result?.idToken)
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

    open func renewTokens(completion: @escaping (Bool) -> Void) {
        silentTokenRenewal(force: true){(success) in
            if(success){
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func silentTokenRenewal(force: Bool = false, completion: @escaping (Bool) -> Void){
        //export token dictionary : token: @escaping ([String : String]) -> Void?
        // should the tokens be stored as a member variable or a closure?
        
        // TODO: add more exceptions
        do {
            let application = try MSALPublicClientApplication.init(clientId: self.clientId, authority: self.authority)
            let thisUser = try self.getUserByPolicy(withUsers: application.users(), forPolicy: self.SignupOrSigninPolicy)
            if (thisUser != nil) {
                // issue w/ forcing reset : you need a UUID look into this
           //     application.acquireTokenSilent(forScopes: self.scopes, user: thisUser, authority: self.authority, forceRefresh: force,correlationId: UUID!, completionBlock:){(result, error) in
                application.acquireTokenSilent(forScopes: self.scopes, user: thisUser, authority: self.authority){(result, error) in
                    if error == nil {
                        self.token["access_token"] = result?.accessToken!
                        self.token["id_token"] = result?.idToken!
                        
                        completion(true)
                    } else if (error! as NSError).code == MSALErrorCode.interactionRequired.rawValue {
                        // requires re sign in to get token
                        application.acquireToken(forScopes: self.scopes, user: thisUser){(result, error) in
                            if error == nil {
                                self.token["accessToken"] = result?.accessToken!
                                self.token["idToken"] = result?.idToken!
                                
                                completion(true)

                            } else {
                                print("Could not acquire new token: \(error ?? "No error informarion" as! Error)")
                                self.token.removeAll()
                                completion(false)                        }
                        }
                    } else {
                        print("Could not acquire new token: \(error ?? "No error informarion" as! Error)")
                        self.token.removeAll()
                        completion(false)
                    }

            }
            } else {
                print("user is not in system, no tokens available")
                self.token.removeAll()
                completion(false)
            }
        } catch {
            print("error occurred") // this could be if user doesn't exist -> then will go to in login TODO handle errors better
            self.token.removeAll()
            completion(false)
        }
    }
    
    open func isAuthenticated(completion: @escaping (Bool) -> Void) {
        silentTokenRenewal(){(isAuthenticated: Bool) in
            if(isAuthenticated){
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func getUserByPolicy (withUsers: [MSALUser], forPolicy: String) throws -> MSALUser? {
        let forPolicy2 = forPolicy.lowercased()// - check to see if this works without this line
        
        for user in withUsers {
            
            if (user.userIdentifier().components(separatedBy: ".")[0].hasSuffix(forPolicy2)) {
                return user
            }
        }
        return nil
    }
    
    open func getClaimsFromToken(_ token: String) -> [String: Any] {
        if (!token.isEmpty) {
            return convertTokenToClaims(token)
        } else {
            return [String: Any]()
        }
    }
    
    open func getIdTokenClaims() -> [String: Any] {
        let idToken = getIdToken()
        return getClaimsFromToken(idToken)
    }

    open func getAccessTokenClaims() -> [String: Any] {
        let accessToken = getAccessToken()
        return getClaimsFromToken(accessToken)
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
        var accessToken = String()
        silentTokenRenewal(){(success) in
            if(success){
                accessToken = self.token["accessToken"]!
            } else {
                accessToken = ""
            }
        }
        return accessToken
    }
    
    open func getIdToken() -> String {
        var idToken = String()
        silentTokenRenewal(){(success) in
            if(success){
                idToken = self.token["idToken"]!
            } else {
                idToken = "" // is there a better practice for this?
            }
        }
        return idToken
    }

    /* -> do we want this functionality?
     open func editProfile() { -> requires a different policy - how do you deal with this?
     }
     */

    open func clearTokens() { // old library had clear Id token
        do {
            self.token.removeAll() // look up more how to store this
            
            let application = try MSALPublicClientApplication.init(clientId: self.clientId, authority: self.authority)
            let thisUser = try self.getUserByPolicy(withUsers: application.users(), forPolicy: self.SignupOrSigninPolicy)
            try application.remove(thisUser)
        } catch {
            print("error occurred signing out/removing tokens")
        }
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
    
}



