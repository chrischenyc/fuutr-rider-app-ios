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
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var phoneNumberVerifyButton: UIButton!
    @IBOutlet weak var phoneNumberVerifyInfoLabel: UILabel!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    var countryCode: UInt64?
    var phoneNumber: String?
    var authServiceTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberVerifyInfoLabel.text = L10n.kPhoneNumberVerificationPrompt
        phoneNumberVerifyButton.isEnabled = false
        facebookLoginButton.readPermissions = ["public_profile", "email"]
        facebookLoginButton.delegate = self
    }
    
    
    @IBAction func phoneNumberChanged(_ sender: Any) {
        phoneNumberTextField.text?.isMobileNumber({ (isMobile, coutryCode, phoneNumber) in
            phoneNumberVerifyButton.isEnabled = isMobile
            self.countryCode = coutryCode
            self.phoneNumber = phoneNumber
        })
    }
    
    @IBAction func phoneNumberVerifyTapped(_ sender: Any) {
        guard let phoneNumber = phoneNumber, countryCode != nil else { return }
        
        // update UI before calling API
        phoneNumberVerifyInfoLabel.text = L10n.kSendingVerificationCode
        phoneNumberTextField.resignFirstResponder()
        phoneNumberTextField.isEnabled = false
        phoneNumberVerifyButton.isEnabled = false
        facebookLoginButton.isEnabled = false
        
        // cancel previous API call
        authServiceTask?.cancel()
        
        // create a new API call
        authServiceTask = UserService().startVerification(forPhoneNumber: phoneNumber, countryCode: 61, completion: { [weak self] (error) in
            DispatchQueue.main.async {
                // reset UI
                self?.phoneNumberVerifyInfoLabel.text = L10n.kPhoneNumberVerificationPrompt
                self?.phoneNumberVerifyButton.isEnabled = true
                self?.phoneNumberTextField.isEnabled = true
                self?.phoneNumberVerifyButton.isEnabled = true
                self?.facebookLoginButton.isEnabled = true
                
                
                if let error = error {
                    self?.showError(error)
                } else {
                    self?.perform(segue: StoryboardSegue.SignIn.showVerifyCode)
                    self?.phoneNumberTextField.text = ""
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
            let verifyCodeViewController = navigationController.topViewController as? VerifyCodeViewController {
            guard let countryCode = countryCode, let phoneNumber = phoneNumber else { return }
            
            verifyCodeViewController.countryCode = countryCode
            verifyCodeViewController.phoneNumber = phoneNumber
        }
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            Defaults[.userSignedIn] = true
                            
                            if Defaults[.userOnboarded] {
                                self.perform(segue: StoryboardSegue.SignIn.fromSignInToMain)
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
