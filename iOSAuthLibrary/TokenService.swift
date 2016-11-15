//
//  TokenService.swift
//  iOSAuthLibrary
//
//  Created by David Collom on 11/4/16.
//  Copyright © 2016 Pariveda Solutions. All rights reserved.
//

import Foundation
import Alamofire

open class TokenService {
    
    required public init() {}
    
    func getTokens(_ auth_code: String, completion: @escaping (_ token: Token) -> Void) {
        let token = Token()
        Alamofire.request("https://login.microsoftonline.com/3ca60f43-0cb5-4822-9ca0-1553fc5382c9/oauth2/v2.0/token?p=B2C_1_SignupAndSignin", method: .post, parameters:
            ["client_id": "ce25c98b-f01d-46ad-936a-62ac28c939e5", "redirect_uri":"urn:ieft:wg:oauth:2.0:oob", "code":auth_code, "grant_type":"authorization_code", "scope":"openid offline_access"]).responseJSON {
            response in
            switch response.result {
            case .success(let JSON as [String: AnyObject]):
                token.id_token = JSON[TokenType.id_token.rawValue] as! String
                token.auth_token = JSON[TokenType.auth_token.rawValue] as! String
                token.refresh_token = JSON[TokenType.refresh_token.rawValue] as! String
                completion(token)
            case .failure:
                print(response.result.error!)
            default: break
            }
        }
    }
}
