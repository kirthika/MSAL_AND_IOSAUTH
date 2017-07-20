//
//  MSALAuthLibrary.swift
//  iOSAuthLibrary
//
//  Copyright © 2017 Pariveda Solutions. All rights reserved.
//

import Foundation
import MSAL

open class MSALAuthLibrary {
    
    let clientId: String
    let tenantName: String
    let SignupOrSigninPolicy: String
    let EditProfilePolicy: String
    var authority: String
    let scopes: [String]
    
    // Format of OIDC Token and Authorization endpoints for Azure AD B2C.
    lazy var endpoint: String = "https://login.microsoftonline.com/tfp/%@/%@"
    
    // MSALAuthLibrary constructor
    required public init(_ clientId: String, _ tenantName: String, _ brand: String, _ scopes: [String]) {
        self.clientId = clientId
        if(brand.caseInsensitiveCompare("Lexus") == .orderedSame){
            self.SignupOrSigninPolicy = "B2C_1_SignupOrSigninLexus"
            self.EditProfilePolicy = "B2C_1_EditProfileLexus"
        } else {
            self.SignupOrSigninPolicy = "B2C_1_SignupOrSigninToyota"
            self.EditProfilePolicy = "B2C_1_EditProfileToyota"
        }
        self.tenantName = tenantName
        self.scopes = scopes
        self.authority = ""
    }
    
    // login: launches broswer, redirects to login page on Azure, allows user to login
    // Leverages MSAL's acquireToken function to force login
    open func login(completion: @escaping (Bool,String) -> Void){
        self.authority = String(format: endpoint, tenantName, SignupOrSigninPolicy)
        
        // Initialize the MSAL App
        if let application = try? MSALPublicClientApplication.init(clientId: self.clientId,authority: self.authority) {
            application.acquireToken(forScopes: self.scopes) { (result, error) in
                // User logged in
                if  error == nil {
                   completion(true,"Successfully Authenticated")
                } else {
                    var errorMsg: String = ""
                    errorMsg = self.handleError(error: error!)
                    // completion(false,errorMsg)
                    let forgotPassAuthority: String = String(format: self.endpoint, self.tenantName, "B2C_1_DefaultPolicy")
                    if let application2 = try? MSALPublicClientApplication.init(clientId: self.clientId, authority: forgotPassAuthority){
                        application2.acquireToken(forScopes: self.scopes){ (result, error) in
                            //do something
                            if error == nil {
                                completion(true,"Successfully changed password")
                            } else {
                                completion(false,errorMsg)
                            }
                        }
                    } else {
                        print("error resetting forgotten password")
                        completion(false, errorMsg)
                    }
                }
            }
            
        } else {
            completion(false,"Error instantiating MSAL application")
        }
        
    }
    
    // isAuthenticated: Validates stored token, refreshes tokens if needed
    open func isAuthenticated(completion: @escaping (Bool,String) -> Void) {
        silentTokenRenewal(){(isAuthenticated, response, details) in
            if(isAuthenticated){
                completion(true,details)
            } else {
                completion(false,details)
            }
        }
    }
    
    // renewTokens: Allows the user to force refresh their tokens
    open func renewTokens(completion: @escaping (Bool) -> Void) {
        silentTokenRenewal(force: true){(success,response,details) in
            if(success){
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    open func getIdTokenClaims(completion: @escaping ([String:Any]) -> Void){
        getIdToken(){(result) in
            completion(self.getClaimsFromToken(result))
        }
    }
    
    open func getAccessTokenClaims(completion: @escaping ([String:Any]) -> Void) {
        getAccessToken(){(result) in
            completion(self.getClaimsFromToken(result))
        }
    }
    
    open func getClaimsFromToken(_ token: String) -> [String: Any] {
        if (!token.isEmpty) {
            return convertTokenToClaims(token)
        } else {
            return [String: Any]()
        }
    }
    
    open func getRoles(completion: @escaping ([String:Any]) -> Void) {
        // change to return an obj
        getIdTokenClaims(){(userInfo) in
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
            completion(obj)
            
        }
    }
    
    open func getAccessToken(completion: @escaping (String) -> Void){
        silentTokenRenewal(){(success,response,details) in
            if(success){
                completion(response["accessToken"]!)
            } else {
                completion("")
            }
        }
    }
    
    open func getIdToken(completion: @escaping (String) -> Void) {
        silentTokenRenewal(){(success,response,details) in
            if(success){
                completion(response["idToken"]!)
            } else {
                completion("")
            }
        }
    }
    
    // logout: Removes user tokens from the MSAL app context
    open func logout(completion: @escaping (Bool,String) -> Void) {
        do {
            let application = try MSALPublicClientApplication.init(clientId: self.clientId, authority: self.authority)
            let thisUser = try self.getUserByPolicy(withUsers: application.users(), forPolicy: self.SignupOrSigninPolicy)
            if(thisUser != nil){
                try application.remove(thisUser)
                completion(true, "Successfully logged out")
            }
        } catch {
            completion(false,"Error info: \(String(describing: error))")
        }
    }
    
    // editProfile: Allows the user to edit their profile on Azure page for editing
    open func editProfile(completion: @escaping (Bool, String) -> Void) {
        do {
            self.authority = String(format: self.endpoint, self.tenantName, self.EditProfilePolicy)
            let application = try MSALPublicClientApplication.init(clientId: self.clientId, authority: self.authority)
            let thisUser = try self.getUserByPolicy(withUsers: application.users(), forPolicy: self.EditProfilePolicy)
            application.acquireToken(forScopes: self.scopes, user: thisUser ) { (result, error) in
                if error == nil {
                    completion(true,"Successfully edited profile")
                } else {
                    completion(false, "Could not edit profile: \(error ?? "No error informarion" as! Error)")
                }
            }
        } catch {
            completion(false, "Error instantiating application")
        }
    }
    
    // Internal functions for library
    
    // silentTokenRenewal: Returns valid tokens, leverages MSAL acquireTokenSilent to refresh tokens or redirect to login
    func silentTokenRenewal(force: Bool = false, completion: @escaping (_ success: Bool,_ tokens: [String:String],_ details: String) -> Void){
        do {
            self.authority = String(format: endpoint, tenantName, SignupOrSigninPolicy)
            let application = try MSALPublicClientApplication.init(clientId: self.clientId, authority: self.authority)
            let thisUser = try self.getUserByPolicy(withUsers: application.users(), forPolicy: self.SignupOrSigninPolicy)
            if (thisUser != nil) {
                let uuid : UUID = getUUIDTimeBased()
                application.acquireTokenSilent(forScopes: self.scopes, user: thisUser, authority: self.authority, forceRefresh: force, correlationId: uuid){(result,error) in
                    if error == nil {
                        var response: [String:String] = [:]
                        response["accessToken"] = result?.accessToken!
                        response["idToken"] = result?.idToken!
                        completion(true,response,"Successfully authenticated")
                    } else if (error! as NSError).code == MSALErrorCode.interactionRequired.rawValue {
                        application.acquireToken(forScopes: self.scopes, user: thisUser){(result, error) in
                            if error == nil {
                                var response: [String:String] = [:]
                                response["accessToken"] = result?.accessToken!
                                response["idToken"] = result?.idToken!
                                completion(true,response,"Successfully authenticated")
                            } else {
                                var errorMsg: String = ""
                                errorMsg = self.handleError(error: error!)
                                print(errorMsg)
                                completion(false,[:],errorMsg)
                            }
                        }
                        //check flow here
                    } else if (error! as NSError).code == MSALErrorCode.invalidClient.rawValue{
                        completion(false,[:],"Error info: \(String(describing: error)) Invalid Client")
                    } else {
                        completion(false,[:], "Could not acquire new token: \(error ?? "No error informarion" as! Error)")
                    }
                }
            } else {
                completion(false,[:],"Not authenticated")
            }
        } catch {
            completion(false,[:],"Error occurred instantiating application")
        }
    }
    
    // getUUIDTimeBased: returns a UUID based on time to minimize possible collisions
    func getUUIDTimeBased() -> UUID {
        // time based uuid, swift supported uuid is randomly generated
        var uuid: uuid_t = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
        withUnsafeMutablePointer(to: &uuid) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 16) {
                uuid_generate_time($0)
            }
        }
        return UUID(uuid: uuid)
    }
    
    // getUserByPolicy: gets a MSAL user that has a policy
    // Leveraged in logout, editProfile, silentTokenRenewal
    func getUserByPolicy (withUsers: [MSALUser], forPolicy: String) throws -> MSALUser? {
        for user in withUsers {
            if (user.userIdentifier().components(separatedBy: ".")[0].hasSuffix(forPolicy.lowercased())) {
                return user
            }
        }
        return nil
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
    
    func handleError(error: Error) -> String {
        if (error as NSError).code == MSALErrorCode.noAccessTokenInResponse.rawValue{
            return "Error info: \(String(describing: error)) No access token in response"
        } else if (error as NSError).code == MSALErrorCode.userCanceled.rawValue{
            return "Error info: \(String(describing: error)) User cancelled login"
        } else if (error as NSError).code == MSALErrorCode.authorizationFailed.rawValue{
            return "Error info: \(String(describing: error)) Authorization failed"
        } else {
            return "Could not acquire new token: \(String(describing: error))"
        }
    }
    
}
