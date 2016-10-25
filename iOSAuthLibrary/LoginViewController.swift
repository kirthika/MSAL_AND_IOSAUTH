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
        let tenant = "/fe14a1c0-578a-42fe-bb99-2bcc77bcc761"
        let oauth = "/oauth2/v2.0"
        let authorize = "/authorize"
        let policy = "B2C_1_toss"
        let clientid = "93406a76-dc2a-4fa9-a900-25f8151762c8"
        let redirecturiencoded = "urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob"
        let scope = "openid"
        let responsetype = "id_token"
        let responsemode = "query"
        let prompt = "login"
        let state = "currenttempstate"
        
        let url = domain +
            tenant +
            oauth +
            authorize +
            "?p=" + policy +
            "&client_id=" + clientid +
            "&redirect_uri=" + redirecturiencoded +
            "&scope=" + scope +
            "&state=" + state +
            "&response_type=" + responsetype +
            "&response_mode=" + responsemode +
            "&prompt=" + prompt
        let nsURL = URL(string: url)
        
        print(url)
        
        /*let nsURL = NSURL (string: "https://login.microsoftonline.com/tyrtsi.onmicrosoft.com/oauth2/v2.0/authorize?p=B2C_1_SignupAndSignin&client_Id=ce25c98b-f01d-46ad-936a-62ac28c939e5&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&scope=openid&response_type=id_token&response_mode=query");*/
        let request = URLRequest(url: nsURL!);
        loginView.delegate = self
        loginView.loadRequest(request)
        // Do any additional setup after loading the view.
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open func webViewDidStartLoad(_ loginView: UIWebView) {
        print("started")
    }
    
    open func webViewDidFinishLoad(_ loginView: UIWebView) {
        print("finished")
    }
    
    open func webView(_ loginView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print(request.url)
        if (navigationType == UIWebViewNavigationType.linkClicked) {
            let url = request.url
            let scheme = url?.scheme
            if (scheme == "urn:ietf:wg:oauth:2.0:oob") {
                // Update the url as needed
                
                // Now handled the url by asking the app to open it
                return false; // don't let the webview process it.
            }
        }
        
        return true;
    }
    
}
