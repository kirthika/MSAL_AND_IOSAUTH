//
//  MockKeychainService.swift
//  iOSAuthLibrary
//
//  Created by Toyota Project Team on 11/2/16.
//  Copyright © 2016 Pariveda Solutions. All rights reserved.
//

import Foundation

class MockKeychainService: KeychainService {
    var mockToken = MockToken()
    
    override func storeToken(_ token: String, _ tokenType: String) {
        if (tokenType == TokenType.id_token.rawValue) {
            mockToken.id_token = token
        }
        else if (tokenType == TokenType.auth_token.rawValue) {
            mockToken.auth_token = token
        }
        else if (tokenType == TokenType.refresh_token.rawValue) {
            mockToken.refresh_token = token
        }
        super.storeToken(token, tokenType)
    }
    
    override func getToken(_ tokenType: String) -> String {
        if (tokenType == TokenType.id_token.rawValue) {
            return mockToken.id_token
        }
        else if (tokenType == TokenType.auth_token.rawValue) {
            return mockToken.auth_token
        }
        else if (tokenType == TokenType.refresh_token.rawValue) {
            return mockToken.refresh_token
        }
        else {
            return ""
        }
    }
}
