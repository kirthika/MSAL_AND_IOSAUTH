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
    
    public func storeToken(_ token: String, _ tokenType: String) -> Bool {
        do {
            try keychain.set(token, key: tokenType)
            return true
        } catch let error {
            return false
        }
    }
    
    public func getToken(_ tokenType: String) -> String {
        var id_token: String
        do {
            try id_token = keychain.get(tokenType)!
        } catch let error {
            return ""
        }
        return id_token
    }
}
