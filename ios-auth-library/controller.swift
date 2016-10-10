//
//  LoginViewController.swift
//  ios-auth-library
//
//  Created by David Collom on 10/10/16.
//  Copyright © 2016 Pariveda Solutions. All rights reserved.
//


import UIKit

class LoginViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL (string: "https://login.microsoftonline.com/tyrtsi.onmicrosoft.com/oauth2/v2.0/authorize?p=B2C_1_SignupAndSignin&client_Id=ce25c98b-f01d-46ad-936a-62ac28c939e5&nonce=defaultNonce&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&scope=openid&response_type=id_token&prompt=login");
        let requestObj = NSURLRequest(URL: url!);
        loginView.loadRequest(requestObj);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}