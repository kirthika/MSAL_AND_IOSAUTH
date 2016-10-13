//
//  isJWTValid.swift
//
//  Created by Toyota Project Team on 10/13/16.
//
//

import JWT

public class AuthLibrary {
    
    public init() { }
    
    public func isJwtValid(token: String) -> Bool {
        let algorithmName = "RS256"
        let claims = JWT.decodeMessage(token).options(true)
        if ((claims.decode) != nil) {
            print(claims.decode)
            return true
        }
        else {
            return false
        }
    }
    
}
