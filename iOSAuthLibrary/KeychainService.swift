//
//  Keychain.swift
//  iOSAuthLibrary
//
//  Created by David Collom on 10/27/16.
//  Copyright © 2016 Pariveda Solutions. All rights reserved.
//

import Foundation
import KeychainAccess

open class KeychainService {
    
    let authService = "com.parivedasolutions.iOSAuthLibrary"
    
    required public init() {}
    
    public func KeychainConstructor() -> Keychain {
        return Keychain(service: authService)
    }
    
    public func storeToken(_ token: String, _ tokenType: String) {
        do {
            try KeychainConstructor().set(token, key: tokenType)
        } catch let error {
            print(error)
        }
    }
    
    public func getToken(_ tokenType: String) -> String {
        print(tokenType)
        var id_token: String
        do {
            try id_token = KeychainConstructor().get(tokenType)!
        } catch let error {
            print(error)
            print("broken get")
            return ""
        }
        return id_token
    }
}
