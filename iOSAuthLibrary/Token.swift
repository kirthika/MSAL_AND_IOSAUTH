//
//  Token.swift
//  iOSAuthLibrary
//
//  Created by Pariveda Solutions.
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
