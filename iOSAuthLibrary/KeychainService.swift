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
        var id_token: String
        do {
            print(keychain)
            print(keychain.allKeys())
            try id_token = keychain.get(tokenType)!
        } catch let error {
            print(error)
            return ""
        }
        return id_token
    }
}
