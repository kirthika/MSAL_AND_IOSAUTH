//
//  LoginViewController.swift
//  ios-auth-library
//
//  Created by David Collom on 10/11/16.
//  Copyright Â© 2016 Pariveda Solutions. All rights reserved.
//

import UIKit

open class LoginViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet open var loginView: UIWebView!
    @IBOutlet open var activityView: UIActivityIndicatorView!
    open var state: String
    open var brand: String
    
    required public init?(coder aDecoder: NSCoder) {
        state = ""
        brand = ""
        activityView.hidesWhenStopped = true
        super.init(coder: aDecoder)
    }
    
    init() {
        state = ""
        brand = ""
        activityView.hidesWhenStopped = true
        super.init(nibName: nil, bundle: nil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        let azureProps = PListService("azure")
        var brandTag = ""
        if (brand == "Lexus") {
            brandTag = "_lexus"
        }
        let url = azureProps.getProperty("domain") +
            azureProps.getProperty("tenant") +
            azureProps.getProperty("oauth") +
            azureProps.getProperty("authorize") +
            "?p=" + azureProps.getProperty("policyLogin") + brandTag +
            "&client_id=" + azureProps.getProperty("clientId") +
            "&redirect_uri=" + azureProps.getProperty("redirectURI") +
            "&scope=" + azureProps.getProperty("scope") +
            "&state=" + state +
            "&response_type=" + azureProps.getProperty("responseType") +
            "&response_mode=" + azureProps.getProperty("responseMode") +
            "&prompt=" + azureProps.getProperty("prompt")
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
                let service = TokenService(brand)
                service.getTokens(auth_code!) {
                    (token: Token) in
                    let keychainService = KeychainService()
                    keychainService.storeToken(token.id_token, TokenType.id_token.rawValue)
                    keychainService.storeToken(token.refresh_token, TokenType.refresh_token.rawValue)
                    
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
                    var brandTag = ""
                    if (brand == "Lexus") {
                        brandTag = "_lexus"
                    }
                    let url = azureProps.getProperty("domain") +
                        azureProps.getProperty("tenant") +
                        azureProps.getProperty("oauth") +
                        azureProps.getProperty("authorize") +
                        "?p=" + azureProps.getProperty("policyReset") + brandTag +
                        "&client_id=" + azureProps.getProperty("clientId") +
                        "&redirect_uri=" + azureProps.getProperty("redirectURI") +
                        "&scope=openid" +
                        "&state=" + state +
                        "&response_type=id_token" +
                        "&response_mode=" + azureProps.getProperty("responseMode") +
                        "&prompt=" + azureProps.getProperty("prompt")
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
