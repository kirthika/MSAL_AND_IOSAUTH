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
    
    public func getToken() -> String {
        print("in getToken func")
        var id_token: String
        print("before try")
        do {
            id_token = try keychain.getString("id_token")!
        } catch let error {
            print(error)
            id_token = ""
        }
        if (id_token == nil) {
            id_token = ""
        }
        return id_token
    }
    
    public func removeTokens() {
        do {
            try keychain.removeAll()
        } catch let error {
            print(error)
        }
    }
}
