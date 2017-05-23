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
    open var clientId: String
    open var envConfig: String
    open var brand: String
    open var resource: String
    open var scopes: [String]
    
    required public init?(coder aDecoder: NSCoder) {
        state = ""
        clientId = ""
        envConfig = ""
        brand = ""
        resource = ""
        scopes = []
        super.init(coder: aDecoder)
    }
    
    init() {
        state = ""
        clientId = ""
        envConfig = ""
        brand = ""
        resource = ""
        scopes = []
        super.init(nibName: nil, bundle: nil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        let azureProps = PList("azure")
        let envProps = PList(envConfig.lowercased() + "-tenant")
        
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
            scopeUrl += " " + envProps.getProperty("scopeAccess") + resource + "/" + scope
        }
        
        let encodedScopeUrl = scopeUrl
            .replacingOccurrences(of: " ", with: "+")
            .addingPercentEncoding(withAllowedCharacters: .urlUserAllowed)  // replaces "#%/:<>?@[\]^` with percent encoding
        
        let url = azureProps.getProperty("domain") +
            envProps.getProperty("tenant") +
            azureProps.getProperty("oauth") +
            azureProps.getProperty("authorize") +
            "?p=\(policy)" +
            "&client_id=\(clientId)" +
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
                let service = TokenService(brand, clientId, envConfig, false)
                service.getTokens(auth_code!) {
                    (token: Token) in
                    let authLibrary = AuthLibrary(self.brand, self.clientId, self.envConfig)
                    let keychainService = KeychainService()
                    if (authLibrary.isJwtValid(token.id_token)) {
                        keychainService.storeToken(token.id_token, TokenType.id_token.rawValue)
                        keychainService.storeToken(token.refresh_token, TokenType.refresh_token.rawValue)
                        keychainService.storeToken(token.access_token, TokenType.access_token.rawValue)
                        
                        // Redirect back to called controller
                        if (self.presentingViewController != nil) {
                            let viewController = self.presentingViewController!.storyboard!.instantiateViewController(withIdentifier: state!)
                            self.presentingViewController!.addChildViewController(viewController)
                            self.presentingViewController!.view!.addSubview(viewController.view)
                        }
                        
                        self.activityView.stopAnimating()
                        self.dismiss(animated: true, completion: nil)
                    } else {    // Id Token is invalid, don't store and display error alert
                        let azureProps = PList("azure")
                        let alert = UIAlertController(title: "Error", message: azureProps.getProperty("invalidTokenErrorMsg"), preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: {
                            (alert: UIAlertAction!) in
                            keychainService.removeTokens()
                            self.activityView.stopAnimating()
                            self.dismiss(animated: true, completion: nil)
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else if (errorRange != nil) {
                // Password Reset
                let forgotPassword = url?.range(of: "AADB2C90118")
                if (forgotPassword != nil) {
                    let azureProps = PList("azure")
                    let envProps = PList(envConfig.lowercased() + "-tenant")
                    var policy = ""
                    if (brand == "lexus") {
                        policy = azureProps.getProperty("policyResetLexus")
                    }
                    else {
                        policy = azureProps.getProperty("policyReset")
                    }
                    let url = azureProps.getProperty("domain") +
                        envProps.getProperty("tenant") +
                        azureProps.getProperty("oauth") +
                        azureProps.getProperty("authorize") +
                        "?p=\(policy)" +
                        "&client_id=\(clientId)" +
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
