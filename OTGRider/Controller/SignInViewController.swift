//
//  SignInViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 31/10/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SwiftyUserDefaults

class SignInViewController: UIViewController {
    
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var mobileNextButton: UIButton!
    @IBOutlet weak var mobileVerifyInfoLabel: UILabel!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mobileNextButton.isEnabled = false
        facebookLoginButton.readPermissions = ["public_profile", "email"]
        facebookLoginButton.delegate = self
    }
    
    
    @IBAction func mobileChanged(_ sender: Any) {
        if let mobile = mobileTextField.text {
            // TODO: format mobile number as 04xx xxx xxx
        }
        
        mobileNextButton.isEnabled = mobileTextField.text?.isAustralianMobile() ?? false
    }
    
    @IBAction func mobileNextTapped(_ sender: Any) {
        mobileNextButton.isEnabled = false
        mobileVerifyInfoLabel.text = NSLocalizedString("kSendingVerificationCode", comment: "")
        
        // TODO: call API to get verificaiton code
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.perform(segue: StoryboardSegue.SignIn.showMobileVerificationCode)
        })
    }
    
    @IBAction func unwindToSignIn(_ unwindSegue: UIStoryboardSegue) {
        
    }
}


extension SignInViewController: FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil
        {
            // Process error
            log.error("Facebook error: \(error.localizedDescription)")
        }
        else if !result.isCancelled {
            FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "id,name,email"])?
                .start(completionHandler: { (connection, graphResult, error) in
                    if error != nil {
                        // TODO: error handling
                    }
                    else if let profile = graphResult as? [String : String] {
                        log.debug(profile["id"])
                        log.debug(profile["name"])
                        log.debug(profile["email"])
                        log.debug(result.token)
                        
                        // TODO: call API
                        
                        // MOCK: remove this
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            Defaults[.userSignedIn] = true
                            
                            if Defaults[.userOnboarded] {
                                self.perform(segue: StoryboardSegue.SignIn.fromSignInToHome)
                            }
                            else {
                                self.perform(segue: StoryboardSegue.SignIn.fromSignInToOnboard)
                            }
                        })
                    }
                })
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // DO NOTHING???
    }
    
    
}
