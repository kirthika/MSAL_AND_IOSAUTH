//
//  LoginViewController.swift
//  ios-auth-library
//
//  Created by David Collom on 10/11/16.
//  Copyright Â© 2016 Pariveda Solutions. All rights reserved.
//

import UIKit

public class LoginViewController: UIViewController {
    @IBOutlet public var loginView: UIWebView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL (string: "https://login.microsoftonline.com/tyrtsi.onmicrosoft.com/oauth2/v2.0/authorize?p=B2C_1_SignupAndSignin&client_Id=ce25c98b-f01d-46ad-936a-62ac28c939e5&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&scope=openid&response_type=id_token&response_mode=query");
        let requestObj = NSURLRequest(URL: url!);
        loginView.loadRequest(requestObj);
        // Do any additional setup after loading the view.
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
