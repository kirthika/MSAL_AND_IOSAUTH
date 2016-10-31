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
        let tenant = "/tyrtsi.onmicrosoft.com"
        let oauth = "/oauth2/v2.0"
        let authorize = "/authorize"
        let policy = "B2C_1_SignupAndSignin"
        let clientId = "ce25c98b-f01d-46ad-936a-62ac28c939e5"
        let redirectURI = "urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob"
        let scope = "offline_access%20openid"
        let responseType = "code%20id_token"
        let responseMode = "query"
        
        let url = domain +
            tenant +
            oauth +
            authorize +
            "?p=" + policy +
            "&client_id=" + clientId +
            "&redirect_uri=" + redirectURI +
            "&scope=" + scope +
            "&state=" + state +
            "&response_type=" + responseType +
            "&response_mode=" + responseMode
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
            
            print("state: " + state!)
            print("code: " + auth_code!)
            print("token: " + id_token!)
            
            let keychainService = KeychainService()
            keychainService.storeToken(id_token!, TokenType.id_token.rawValue)
            
            dismiss(animated: true, completion: nil)
            
            let viewController = storyboard!.instantiateViewController(withIdentifier: state! + "ViewController")
            self.addChildViewController(viewController)
            self.view!.addSubview(viewController.view)
        }
        return true;
    }
    
}
