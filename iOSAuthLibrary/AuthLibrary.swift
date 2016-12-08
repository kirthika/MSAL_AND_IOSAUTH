//
//  isJWTValid.swift
//
//  Created by Pariveda Solutions.
//

open class AuthLibrary {
    
    var keychainService: KeychainService
    let brand: String
    let azureProps: PListService
    
    required public init(_ branding: String) {
        keychainService = KeychainService()
        brand = branding.lowercased()
        azureProps = PListService("azure")
    }

    open func isAuthenticated(completion: @escaping (Bool) -> Void) {
        let id_token = keychainService.getToken(TokenType.id_token.rawValue)
        if (!id_token.isEmpty) {
            completion(isJwtValid(id_token))
        } else {
            let refresh_token = keychainService.getToken(TokenType.refresh_token.rawValue)
            if (!refresh_token.isEmpty) {
                let tokenService = TokenService(brand, true)
                tokenService.getTokens(refresh_token) {
                    (token: Token) in
                    self.keychainService.storeToken(token.id_token, TokenType.id_token.rawValue)
                    self.keychainService.storeToken(token.refresh_token, TokenType.refresh_token.rawValue)
                    completion(self.isJwtValid(token.id_token))
                }
            }
            else {
                completion(false)
            }
        }
    }
    
    open func login(state: String) -> LoginViewController {
        let storyboard = UIStoryboard (name: "Login", bundle: Bundle(for: LoginViewController.self))
        let viewController: LoginViewController = storyboard.instantiateInitialViewController() as! LoginViewController
        viewController.state = state
        viewController.brand = brand
        return viewController
    }
    
    open func isJwtValid(_ token: String?) -> Bool {
        var claims = convertTokenToClaims(token!)
        let issuer = claims["iss"] as! String
        print(issuer)
        print(azureProps.getProperty("tenant"))
        if ("/" + issuer == azureProps.getProperty("tenant")) {
            print(true)
            return true
        }
        else {
            print(false)
            return false
        }
    }
    
    open func getClaims() -> [String: Any] {
        let id_token = keychainService.getToken(TokenType.id_token.rawValue)
        if (!id_token.isEmpty) {
            return convertTokenToClaims(id_token)
        } else {
            return [String: Any]()
        }
    }
    
    open func clearIdToken() {
        keychainService.removeToken(TokenType.id_token.rawValue)
    }
    
    open func clearTokens() {
        keychainService.removeTokens()
    }
    
    func convertTokenToClaims(_ token: String) -> [String: Any] {
        let jwt = token.components(separatedBy: ".")
        var claims = jwt[1]
        switch (claims.characters.count % 4) // Pad with trailing '='s
        {
            case 0: break; // No pad chars in this case
            case 1: claims += "==="; break; // Three pad chars
            case 2: claims += "=="; break; // Two pad chars
            case 3: claims += "="; break; // One pad char
            default: print("Illegal base64 string!")
        }
        
        do {
            let parsedData = try JSONSerialization.jsonObject(with: Data(base64Encoded: claims)!, options: .allowFragments) as! [String:Any]
            return parsedData
        } catch let error as NSError {
            print(error)
        }
        
        return [String: Any]()
    }
}
