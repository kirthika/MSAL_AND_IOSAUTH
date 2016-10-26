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
        let prompt = "login"
        
        let url = domain +
            tenant +
            oauth +
            authorize +
            "?p=" + policy +
            "&client_id=" + clientId +
            "&redirect_uri=" + redirectURI +
            "&scope=" + scope +
            "&response_type=" + responseType +
            "&response_mode=" + responseMode +
            "&prompt=" + prompt
        loginView.loadRequest(URLRequest(url: URL(string: url)!))
        loginView.delegate = self
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print(request.url)
        print(navigationType)
        if (navigationType == UIWebViewNavigationType.linkClicked) {
            print("clickedLink")
            let url = request.url
            let scheme = url?.scheme
            print(scheme)
            if (scheme == "urn:ietf:wg:oauth:2.0:oob") {
                print("redirect")
                // Now handled the url by asking the app to open it
                return false; // don't let the webview process it.
            }
        }
        let url = request.url?.absoluteString
        print(url)
        
        // Retrieve code and id token if they exist
        if (url?.range(of: "urn:ietf:wg:oauth:2.0:oob") != nil && url?.range(of: "code=") != nil && url?.range(of: "&id_token=") != nil) {
            let codeIndex = url?.range(of: "code=")?.lowerBound
            let tokenIndex = url?.range(of: "&id_token=")?.lowerBound
            let auth_code = url?.substring(with: codeIndex!..<tokenIndex!)
            let id_token = url?.substring(from: tokenIndex!)
            
            print(codeIndex)
            print(tokenIndex)
            print(auth_code)
            print(id_token)
            return true;
        }
        return false;
    }
    
}
