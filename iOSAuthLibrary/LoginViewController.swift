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

        let authProps = PListService("auth")
        let url = authProps.getProperty("domain") +
            authProps.getProperty("tenant") +
            authProps.getProperty("oauth") +
            authProps.getProperty("authorize") +
            "?p=" + authProps.getProperty("policy") +
            "&client_id=" + authProps.getProperty("clientId") +
            "&redirect_uri=" + authProps.getProperty("redirectURI") +
            "&scope=" + authProps.getProperty("scope") +
            "&state=" + authProps.getProperty("state") +
            "&response_type=" + authProps.getProperty("responseType") +
            "&response_mode=" + authProps.getProperty("responseMode") +
            "&prompt=" + authProps.getProperty("prompt")
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
