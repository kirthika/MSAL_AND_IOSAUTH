//
//  MSALAuthLibrary.swift
//  iOSAuthLibrary
//
//  Copyright © 2017 Pariveda Solutions. All rights reserved.
//

import Foundation
import MSAL

open class MSALAuthLibrary {
    
 /*todos:
     1.) get right sign in/edit policies
     2.) UUID
     Ask about these ^
     
     work on v
     3.) introduce logging like the Android application or pass string back? more exceptions?
     4.) test*/
  
    let clientId: String
    let tenantName: String
    let SignupOrSigninPolicy: String
    let EditProfilePolicy: String
    var authority: String
    let scopes: [String]
    
    // Format of OIDC Token and Authorization endpoints for Azure AD B2C.
    lazy var endpoint: String = "https://login.microsoftonline.com/tfp/%@/%@"
    
    required public init(_ clientId: String, _ tenantName: String, _ SignupOrSigninPolicy: String,_ EditProfilePolicy: String, _ scopes: [String]) {
        self.clientId = clientId
        //self.SignupOrSigninPolicy = brand.equalsIgnoreCase("Lexus") ? "B2C_1_SignupOrSigninLexus": "B2C_1_SignupOrSigninToyota"
        //self.EditProfilePolicy = brand.equalsIgnoreCase("Lexus") ? "B2C_1_EditProfileLexus": "B2C_1_EditProfileToyota"
        // todo: pass in brand and correct policies based on this
        
        self.SignupOrSigninPolicy = SignupOrSigninPolicy
        self.EditProfilePolicy = EditProfilePolicy
        self.tenantName = tenantName
        self.scopes = scopes
        self.authority = ""
    }
    
    open func login(completion: @escaping (Bool) -> Void){
        self.authority = String(format: endpoint, tenantName, SignupOrSigninPolicy)
        if let application = try? MSALPublicClientApplication.init(clientId: self.clientId,authority: self.authority) {
            application.acquireToken(forScopes: self.scopes) { (result, error) in
                if  error == nil {
                    completion(true)
                } else if (error! as NSError).code == MSALErrorCode.noAccessTokenInResponse.rawValue{
                    print("error occurred getting access token, check scopes you're passing in")
                    print("Error info: \(String(describing: error))")
                    completion(false)
                } else if (error! as NSError).code == MSALErrorCode.invalidClient.rawValue{
                    print("invalid client")
                    print("Error info: \(String(describing: error))")
                    completion(false)
                } else if (error! as NSError).code == MSALErrorCode.userNotFound.rawValue{
                    print("invalid user")
                    print("Error info: \(String(describing: error))")
                    completion(false)
                } else if (error! as NSError).code == MSALErrorCode.userCanceled.rawValue{
                    print("user cancelled login")
                    print("Error info: \(String(describing: error))")
                    completion(false)
                } else if (error! as NSError).code == MSALErrorCode.authorizationFailed.rawValue{
                    print("error occurred authorizing")
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
        silentTokenRenewal(force: true){(success,response) in
            if(success){
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func silentTokenRenewal(force: Bool = false, completion: @escaping (_ success: Bool,_ tokens: [String:String]) -> Void){
        // TODO: add more exceptions
        do {
            self.authority = String(format: endpoint, tenantName, SignupOrSigninPolicy)
            let application = try MSALPublicClientApplication.init(clientId: self.clientId, authority: self.authority)
            let thisUser = try self.getUserByPolicy(withUsers: application.users(), forPolicy: self.SignupOrSigninPolicy)
            if (thisUser != nil) {
            let uuid = UUID()
            application.acquireTokenSilent(forScopes: self.scopes, user: thisUser, authority: self.authority, forceRefresh: force, correlationId: uuid){(result,error) in
      //          application.acquireTokenSilent(forScopes: self.scopes, user: thisUser, authority: self.authority){(result, error) in
                if error == nil {
                    var response: [String:String] = [:]
                    response["accessToken"] = result?.accessToken!
                    response["idToken"] = result?.idToken!
                    completion(true,response)
                } else if (error! as NSError).code == MSALErrorCode.interactionRequired.rawValue {
                    application.acquireToken(forScopes: self.scopes, user: thisUser){(result, error) in
                        if error == nil {
                            var response: [String:String] = [:]
                            response["accessToken"] = result?.accessToken!
                            response["idToken"] = result?.idToken!
                            completion(false,[:])
                        } else if (error! as NSError).code == MSALErrorCode.noAccessTokenInResponse.rawValue{
                            print("error occurred getting access token, check scopes you're passing in")
                            print("Error info: \(String(describing: error))")
                            completion(false,[:])
                        } else if (error! as NSError).code == MSALErrorCode.userCanceled.rawValue{
                            print("user cancelled login")
                            print("Error info: \(String(describing: error))")
                            completion(false,[:])
                        } else if (error! as NSError).code == MSALErrorCode.authorizationFailed.rawValue{
                            print("error occurred authorizing")
                            print("Error info: \(String(describing: error))")
                            completion(false,[:])
                        } else {
                            print("Could not acquire new token: \(error ?? "No error informarion" as! Error)")
                            completion(false,[:])                        }
                        }
                    } else if (error! as NSError).code == MSALErrorCode.invalidClient.rawValue{
                        print("invalid client")
                        print("Error info: \(String(describing: error))")
                        completion(false,[:])
                    } else if (error! as NSError).code == MSALErrorCode.userNotFound.rawValue{
                        print("invalid user")
                        print("Error info: \(String(describing: error))")
                        completion(false,[:])
                    } else {
                        print("Could not acquire new token: \(error ?? "No error informarion" as! Error)")
                        completion(false,[:])
                    }

                }
            } else {
                print("user is not in system, no tokens available")
                completion(false,[:])
            }
        } catch {
            print("error occurred") // this could be if user doesn't exist -> then will go to in login TODO handle errors better
            completion(false,[:])
        }
    }
    
    open func isAuthenticated(completion: @escaping (Bool) -> Void) {
        silentTokenRenewal(){(isAuthenticated, response) in
            if(isAuthenticated){
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func getUserByPolicy (withUsers: [MSALUser], forPolicy: String) throws -> MSALUser? {
        for user in withUsers {
            if (user.userIdentifier().components(separatedBy: ".")[0].hasSuffix(forPolicy.lowercased())) {
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
        silentTokenRenewal(){(success,response) in
            if(success){
                accessToken = response["accessToken"]!
            } else {
                accessToken = ""
            }
        }
        return accessToken
    }
    
    open func getIdToken() -> String {
        var idToken = String()
        silentTokenRenewal(){(success,response) in
            if(success){
                idToken = response["idToken"]!
            } else {
                idToken = ""
            }
        }
        return idToken
    }

    open func logout() { // old iOS library had clear Id token
        do {            
            let application = try MSALPublicClientApplication.init(clientId: self.clientId, authority: self.authority)
            let thisUser = try self.getUserByPolicy(withUsers: application.users(), forPolicy: self.SignupOrSigninPolicy)
            if(thisUser != nil){
                try application.remove(thisUser)
            }
        } catch {
            // could be no token in cache or that that user does not exist at this position
            print("error occurred signing out/removing tokens")
        }
    }
    
    open func editProfile(completion: @escaping (Bool) -> Void) {
        do {
            self.authority = String(format: self.endpoint, self.tenantName, self.EditProfilePolicy)
            let application = try MSALPublicClientApplication.init(clientId: self.clientId, authority: self.authority)
            let thisUser = try self.getUserByPolicy(withUsers: application.users(), forPolicy: self.EditProfilePolicy)
            application.acquireToken(forScopes: self.scopes, user: thisUser ) { (result, error) in
                if error == nil {
                    completion(true)
                } else {
                    // print("Could not edit profile: \(error ?? "No error informarion" as! Error)")
                    completion(false)
                }
            }
        } catch {
            completion(false)
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



