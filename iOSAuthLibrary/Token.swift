//
//  Token.swift
//  iOSAuthLibrary
//
//  Created by David Collom on 10/28/16.
//  Copyright © 2016 Pariveda Solutions. All rights reserved.
//

import Foundation

public enum TokenType: String {
    case id_token
    case auth_token
    case refresh_token
}

class Token {
    var id_token = ""
    var auth_token = ""
    var refresh_token = ""
}
