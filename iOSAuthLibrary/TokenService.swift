//
//  TokenService.swift
//  iOSAuthLibrary
//
//  Created by Pariveda Solutions.
//
import Foundation
import Alamofire

open class TokenService {
    
    let brand: String
    let refresh: Bool
    required public init(_ branding: String,_ refreshBool: Bool) {
        brand = branding
        refresh = refreshBool
    }
    
    func getTokens(_ auth_code: String, completion: @escaping (_ token: Token) -> Void) {
        let token = Token()
        let azureProps = PListService("azure")
        
        // Get correct policy based on brand
        var policy = ""
        if (brand == "lexus") {
            policy = azureProps.getProperty("policyLexus")
        }
        else {
            policy = azureProps.getProperty("policy")
        }
        
        // Get correct grant type based on if refresh or not
        var grant = ""
        if (refresh) {
            grant = azureProps.getProperty("grantTypeRefresh")
        }
        else {
            grant = azureProps.getProperty("grantType")
        }
        
        let url = azureProps.getProperty("domain") +
            azureProps.getProperty("tenant") +
            azureProps.getProperty("oauth") +
            azureProps.getProperty("token") + "?p=" + policy
        Alamofire.request(url, method: .post, parameters:
            ["client_id": azureProps.getProperty("clientId"), "redirect_uri": azureProps.getProperty("redirectURINonEncoded"), "code": auth_code, "grant_type": grant, "scope": azureProps.getProperty("scopeNonEncoded")]).responseJSON {
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
