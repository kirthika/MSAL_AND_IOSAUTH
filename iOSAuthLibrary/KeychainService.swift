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
    
    public var keychain: Keychain
    
    required public init() {
        self.keychain = Keychain(service: "com.parivedasolutions.iOSAuthLibrary")
            .accessibility(.whenUnlocked)
    }
    
    public func storeToken(_ token: String, _ tokenType: String) {
        do {
            try keychain.set(token, key: tokenType)
        } catch let error {
            print(error)
        }
    }
    
    public func getToken(_ tokenType: String) -> String {
        print(tokenType)
        do {
            try Keychain(service: "com.parivedasolutions.iOSAuthLibrary").set("test", key: "id_token")
        }
        catch let error {
            print(error)
            print("broken set")
        }
        var id_token: String
        var token: String
        do {
            print(Keychain())
            print(Keychain(service: "com.parivedasolutions.iOSAuthLibrary"))
            print(keychain.allKeys())
            try token = Keychain().get("id_token")!
            try id_token = Keychain(service: "com.parivedasolutions.iOSAuthLibrary").get(tokenType)!
        } catch let error {
            print(error)
            print("broken get")
            return ""
        }
        return id_token
    }
}
