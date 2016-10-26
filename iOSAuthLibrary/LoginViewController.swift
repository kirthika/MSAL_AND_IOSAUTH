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
        let clientid = "ce25c98b-f01d-46ad-936a-62ac28c939e5"
        let redirecturiencoded = "urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob"
        let scope = "openid"
        let responsetype = "id_token"
        let responsemode = "query"
        
        let url = domain +
            tenant +
            oauth +
            authorize +
            "?p=" + policy +
            "&client_id=" + clientid +
            "&redirect_uri=" + redirecturiencoded +
            "&scope=" + scope +
            "&response_type=" + responsetype +
            "&response_mode=" + responsemode
        loginView.loadRequest(URLRequest(url: URL(string: url)!))
        loginView.delegate = self
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print(request.url)
        if (navigationType == UIWebViewNavigationType.linkClicked) {
            let url = request.url
            let scheme = url?.scheme
            if (scheme == "urn:ietf:wg:oauth:2.0:oob") {
                print("redirect")
                // Now handled the url by asking the app to open it
                return false; // don't let the webview process it.
            }
        }
        
        return true;
    }
    
}
