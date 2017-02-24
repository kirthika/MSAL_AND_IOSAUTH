//
//  LoginViewController.swift
//  ios-auth-library
//
//  Created by Pariveda Solutions.
//

import UIKit

open class LoginViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet open var loginView: UIWebView!
    @IBOutlet open var activityView: UIActivityIndicatorView!
    open var state: String
    open var brand: String
    open var resource: String
    open var scopes: [String]
    
    required public init?(coder aDecoder: NSCoder) {
        state = ""
        brand = ""
        resource = ""
        scopes = []
        super.init(coder: aDecoder)
    }
    
    init() {
        state = ""
        brand = ""
        resource = ""
        scopes = []
        super.init(nibName: nil, bundle: nil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        let azureProps = PListService("azure")
        
        // Get policy based on brand
        var policy = ""
        if (brand == "lexus") {
            policy = azureProps.getProperty("policyLexus")
        }
        else {
            policy = azureProps.getProperty("policy")
        }
        
        var scopeUrl = azureProps.getProperty("scopeIdRefresh")
        for scope in scopes {
            scopeUrl += " " + azureProps.getProperty("scopeAccess") + resource + "/" + scope
        }
        
        let encodedScopeUrl = scopeUrl
            .replacingOccurrences(of: " ", with: "+")
            .addingPercentEncoding(withAllowedCharacters: .urlUserAllowed)  // replaces "#%/:<>?@[\]^` with percent encoding
        
        let url = azureProps.getProperty("domain") +
            azureProps.getProperty("tenant") +
            azureProps.getProperty("oauth") +
            azureProps.getProperty("authorize") +
            "?p=\(policy)" +
            "&client_id=\(azureProps.getProperty("clientId"))" +
            "&redirect_uri=\(azureProps.getProperty("redirectUri").addingPercentEncoding(withAllowedCharacters: .urlUserAllowed)!)" +
            "&scope=\(encodedScopeUrl!)" +
            "&state=\(state)" +
            "&response_type=\(azureProps.getProperty("responseType"))" +
            "&response_mode=\(azureProps.getProperty("responseMode"))" +
            "&prompt=\(azureProps.getProperty("prompt"))"
        loginView.loadRequest(URLRequest(url: URL(string: url)!))
        loginView.delegate = self
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        // Retrieve code
        let url = request.url?.absoluteString
        let redirectRange = url?.range(of: "urn:ietf:wg:oauth:2.0:oob")
        let stateRange = url?.range(of: "state=")
        let codeRange = url?.range(of: "&code=")
        let errorRange = url?.range(of: "?error=")
        
        if (redirectRange != nil) {
            // Start spinner
            activityView.startAnimating()
            
            if (stateRange != nil && codeRange != nil) {
                let stateUpperIndex = stateRange?.upperBound
                let codeLowerIndex = codeRange?.lowerBound
                let codeUpperIndex = codeRange?.upperBound
                let state = url?.substring(with: stateUpperIndex!..<codeLowerIndex!)
                let auth_code = url?.substring(from: codeUpperIndex!)
                
                // Retrieve tokens using code
                let service = TokenService(brand, false)
                service.getTokens(auth_code!) {
                    (token: Token) in
                    let authLibrary = AuthLibrary(self.brand)
                    let keychainService = KeychainService()
                    let invalidToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IklkVG9rZW5TaWduaW5nS2V5Q29udGFpbmVyLnYyIn0.eyJleHAiOjE0ODc4ODkxODUsIm5iZiI6MTQ4Nzg4NTU4NSwidmVyIjoiMS4wIiwiaXNzIjoiaHR0cHM6Ly9sb2dpbi5taWNyb3NvZnRvbmxpbmUuY29tL2NkNzg2YzQ4LWRhZmItNDFkMS1hY2JmLWQ0ZWU3NzdhZGYwMi92Mi4wLyIsInN1YiI6IjlkZmU3M2JlLWFjNjUtNGMzZC1hNTAzLTRhYzE1MDI1YjA3MCIsImF1ZCI6ImRmMTVjZTRmLWYxZjEtNGM5MC05NTZjLTI5OWU1ZmQ5ZmVhZSIsImlhdCI6MTQ4Nzg4NTU4NSwiYXV0aF90aW1lIjoxNDg3ODg1NTg1LCJnaXZlbl9uYW1lIjoidGltIiwiZmFtaWx5X25hbWUiOiJwdXNhdGVyaSIsIm5hbWUiOiJ1bmtub3duIiwiZW1haWxzIjpbInRwdXNhdGVyaTQ0QGdtYWlsLmNvbSJdLCJ0ZnAiOiJCMkNfMV9TaWdudXBPclNpZ25pblRveW90YSIsImF0X2hhc2giOiJpb0lBS3NQYzVaYlpaNktHVXRMOGVRIn0.BR8YZCX9lN3RzRsmGX6Rzh2bHBQbHQ_miZ1CqKusztP9xiYHAtxIOfgj6W6uWurQ496Rj6W8rUbq64JZFFWG9PxJl_MrpVPcAgXi6ldh46rBASF3JholZqXBPgBULVLkQzoU80SgG808y2_B4_vUFuWqBc_YoxuGODkaCfJ_x6rRKOX8L9ajOe_sfMaC9xJ-3JcjVQmZxXCDHA8RQshiF_d82j4S1B0Ngv1G_zqUu6q-Bd-mfUG7DTSnHeRrduKjxoKG46UCUeGvUlTolJfbVz_xtGZSLSnw9oZhtMp65B-zbkRNiCPua7jtsYSo2qOMK-5zGT6snyJJZQr7BntSHA"
                    if (authLibrary.isJwtValid(invalidToken)) {
                        keychainService.storeToken(token.id_token, TokenType.id_token.rawValue)
                        keychainService.storeToken(token.refresh_token, TokenType.refresh_token.rawValue)
                        keychainService.storeToken(token.access_token, TokenType.access_token.rawValue)
                    } else {
                        print("TOKEN IS INVALID NOT STORING")
                        keychainService.removeTokens()
                        self.activityView.stopAnimating()
                        self.dismiss(animated: true, completion: nil)
                    }
                        
                    // Redirect back to called controller
                    if (self.presentingViewController != nil) {
                        let viewController = self.presentingViewController!.storyboard!.instantiateViewController(withIdentifier: state!)
                        self.presentingViewController!.addChildViewController(viewController)
                        self.presentingViewController!.view!.addSubview(viewController.view)
                    }
                    
                    self.activityView.stopAnimating()
                    
                    // Dismiss webview after new view is established
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else if (errorRange != nil) {
                // Password Reset
                let forgotPassword = url?.range(of: "AADB2C90118")
                if (forgotPassword != nil) {
                    let azureProps = PListService("azure")
                    var policy = ""
                    if (brand == "lexus") {
                        policy = azureProps.getProperty("policyResetLexus")
                    }
                    else {
                        policy = azureProps.getProperty("policyReset")
                    }
                    let url = azureProps.getProperty("domain") +
                        azureProps.getProperty("tenant") +
                        azureProps.getProperty("oauth") +
                        azureProps.getProperty("authorize") +
                        "?p=\(policy)" +
                        "&client_id=\(azureProps.getProperty("clientId"))" +
                        "&redirect_uri=\(azureProps.getProperty("redirectUri").addingPercentEncoding(withAllowedCharacters: .urlUserAllowed)!)" +
                        "&scope=openid" +
                        "&state=\(state)" +
                        "&response_type=id_token" +
                        "&response_mode=\(azureProps.getProperty("responseMode"))" +
                        "&prompt=\(azureProps.getProperty("prompt"))"
                    loginView.loadRequest(URLRequest(url: URL(string: url)!))
                    loginView.delegate = self
                    activityView.stopAnimating()
                }
                
                // Cancel
                let cancel = url?.range(of: "AADB2C90091")
                if (cancel != nil) {
                    activityView.stopAnimating()
                    dismiss(animated: true, completion: nil)
                }
            }
            else {
                activityView.stopAnimating()
                dismiss(animated: true, completion: nil)
            }
        }
        return true;
    }
    
}
