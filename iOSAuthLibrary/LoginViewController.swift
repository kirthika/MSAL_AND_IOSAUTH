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
        
        let domain = "https://login.microsoftonline.com"
        let tenant = "/fe14a1c0-578a-42fe-bb99-2bcc77bcc761"
        let oauth = "/oauth2/v2.0"
        let authorize = "/authorize"
        let policy = "B2C_1_toss"
        let clientid = "93406a76-dc2a-4fa9-a900-25f8151762c8"
        let redirecturiencoded = "urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob"
        let scope = "offline_access openid"
        let responsetype = "code id_token"
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
        let nsURL = NSURL(string: url)
        
        /*let url = NSURL (string: "https://login.microsoftonline.com/tyrtsi.onmicrosoft.com/oauth2/v2.0/authorize?p=B2C_1_SignupAndSignin&client_Id=ce25c98b-f01d-46ad-936a-62ac28c939e5&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&scope=openid&response_type=id_token&response_mode=query");*/
        let requestObj = NSURLRequest(URL: nsURL!);
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
