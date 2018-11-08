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
    
    private var countryCode: UInt64?
    private var phoneNumber: String?
    private var apiTask: URLSessionDataTask?
    private var fbLoginResult: FBSDKLoginManagerLoginResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberVerifyInfoLabel.text = L10n.kPhoneNumberVerificationPrompt
        phoneNumberVerifyButton.isEnabled = false
        facebookLoginButton.readPermissions = ["public_profile", "email"]
        facebookLoginButton.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if FBSDKAccessToken.current() != nil, let fbLoginResult = fbLoginResult {
            authenticateWithFacebook(result: fbLoginResult)
        }
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
        apiTask?.cancel()
        
        // create a new API call
        apiTask = PhoneService().startVerification(forPhoneNumber: phoneNumber, countryCode: 61, completion: { [weak self] (error) in
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
        if unwindSegue.source is SettingsTableViewController {
            fbLoginResult = nil
        }
    }
    
    private func authenticateWithFacebook(result: FBSDKLoginManagerLoginResult) {
        // cancel previous API call
        apiTask?.cancel()
        
        // create a new API call
        showLoading()
        apiTask = AuthService().login(withFacebookToken: result.token.tokenString, completion: { [weak self] (error) in
            
            DispatchQueue.main.async {
                if let error = error {
                    self?.dismissLoading(withMessage: error.localizedDescription)
                }
                else if Defaults[.userOnboarded] {
                    self?.dismissLoading()
                    self?.perform(segue: StoryboardSegue.SignIn.fromSignInToMain, sender: self)
                }
                else {
                    self?.dismissLoading()
                    self?.perform(segue: StoryboardSegue.SignIn.fromSignInToOnboard, sender: self)
                }
            }
        })
    }
}


extension SignInViewController: FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        guard error == nil else {
            log.warning("Facebook error: \(error.localizedDescription)")
            return
        }
        
        guard !result.isCancelled else {
            return
        }
        
        fbLoginResult = result
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        fbLoginResult = nil
    }
}
