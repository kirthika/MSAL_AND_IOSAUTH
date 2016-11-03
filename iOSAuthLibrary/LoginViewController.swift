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
    open var state: String
    
    required public init?(coder aDecoder: NSCoder) {
        state = ""
        super.init(coder: aDecoder)
    }
    
    init() {
        state = ""
        super.init(nibName: nil, bundle: nil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let domain = "https://login.microsoftonline.com"
        let tenant = "/3ca60f43-0cb5-4822-9ca0-1553fc5382c9"
        let oauth = "/oauth2/v2.0"
        let authorize = "/authorize"
        let policy = "B2C_1_SignupAndSignin"
        let clientId = "ce25c98b-f01d-46ad-936a-62ac28c939e5"
        let redirectURI = "urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob"
        let scope = "openid%20offline_access"
        let new_state = "currenttempstate"
        let responseType = "code"
        let responseMode = "query"
        let prompt = "login"
        
        let url = domain +
            tenant +
            oauth +
            authorize +
            "?p=" + policy +
            "&client_id=" + clientId +
            "&redirect_uri=" + redirectURI +
            "&scope=" + scope +
            "&state=" + new_state +
            "&response_type=" + responseType +
            "&response_mode=" + responseMode +
            "&prompt=" + prompt
        print(url)
        loginView.loadRequest(URLRequest(url: URL(string: url)!))
        loginView.delegate = self
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        // Retrieve code and id token if they exist
        let url = request.url?.absoluteString
        let redirectRange = url?.range(of: "urn:ietf:wg:oauth:2.0:oob")
        let stateRange = url?.range(of: "state=")
        let codeRange = url?.range(of: "&code=")
        let tokenRange = url?.range(of: "&id_token=")
        
        if (redirectRange != nil && stateRange != nil && codeRange != nil && tokenRange != nil) {
            let stateUpperIndex = stateRange?.upperBound
            let codeLowerIndex = codeRange?.lowerBound
            let codeUpperIndex = codeRange?.upperBound
            let tokenLowerIndex = tokenRange?.lowerBound
            let tokenUpperIndex = tokenRange?.upperBound
            let state = url?.substring(with: stateUpperIndex!..<codeLowerIndex!)
            let auth_code = url?.substring(with: codeUpperIndex!..<tokenLowerIndex!)
            let id_token = url?.substring(from: tokenUpperIndex!)
            
            print("code: " + auth_code!)
            print("token: " + id_token!)
            
            let keychainService = KeychainService()
            keychainService.storeToken(id_token!, TokenType.id_token.rawValue)
            
            if (presentingViewController != nil) {
                let viewController = presentingViewController!.storyboard!.instantiateViewController(withIdentifier: state!)
                presentingViewController!.addChildViewController(viewController)
                presentingViewController!.view!.addSubview(viewController.view)
            }
            
            dismiss(animated: true, completion: nil)
        }
        return true;
    }
    
}
