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
    
    let brand: String
    required public init(_ branding: String) {
        brand = branding
    }
    
    func getTokens(_ auth_code: String, completion: @escaping (_ token: Token) -> Void) {
        let token = Token()
        let azureProps = PListService("azure")
        var brandTag = ""
        if (brand == "Lexus") {
            brandTag = "_lexus"
        }
        let url = azureProps.getProperty("domain") +
            azureProps.getProperty("tenant") +
            azureProps.getProperty("oauth") +
            azureProps.getProperty("token") + "?p=" + azureProps.getProperty("policyLogin") + brandTag
        Alamofire.request(url, method: .post, parameters:
            ["client_id": azureProps.getProperty("clientId"), "redirect_uri": azureProps.getProperty("redirectURINonEncoded"), "code": auth_code, "grant_type": azureProps.getProperty("grantType"), "scope": azureProps.getProperty("scopeNonEncoded")]).responseJSON {
            response in
            switch response.result {
            case .success(let JSON as [String: AnyObject]):
                token.id_token = JSON[TokenType.id_token.rawValue] as! String
                //token.auth_token = JSON[TokenType.auth_token.rawValue] as! String
                token.refresh_token = JSON[TokenType.refresh_token.rawValue] as! String
                completion(token)
            case .failure:
                print(response.result.error!)
            default: break
            }
        }
    }
}
