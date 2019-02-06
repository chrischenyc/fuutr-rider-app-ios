//
//  SignInViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 31/10/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SwiftyUserDefaults

class SignInViewController: UIViewController {
  
  @IBOutlet weak var backdropView: UIView!
  @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
  @IBOutlet weak var emailSignInButton: UIButton!
  
  private var countryCode: UInt64?
  private var phoneNumber: String?
  private var apiTask: URLSessionDataTask?
  private var fbLoginResult: FBSDKLoginManagerLoginResult?
  
  // MARK: - lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if FBSDKAccessToken.current() != nil, let fbLoginResult = fbLoginResult {
      authenticateWithFacebook(result: fbLoginResult)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let navigationController = segue.destination as? UINavigationController,
      let verifyCodeViewController = navigationController.topViewController as? VerifyCodeViewController {
      guard let countryCode = countryCode, let phoneNumber = phoneNumber else { return }
      
      verifyCodeViewController.countryCode = countryCode
      verifyCodeViewController.phoneNumber = phoneNumber
    }
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - user actions
  //  @IBAction func phoneNumberChanged(_ sender: Any) {
  //    phoneNumberTextField.text?.isMobileNumber({ (isMobile, coutryCode, phoneNumber) in
  //      phoneNumberVerifyButton.isEnabled = isMobile
  //      self.countryCode = coutryCode
  //      self.phoneNumber = phoneNumber
  //    })
  //  }
  
  //  @IBAction func phoneNumberVerifyTapped(_ sender: Any) {
  //    guard let phoneNumber = phoneNumber, let countryCode = countryCode else { return }
  //
  //    // update UI before calling API
  //    phoneNumberTextField.resignFirstResponder()
  //    phoneNumberTextField.isEnabled = false
  //    phoneNumberVerifyButton.isEnabled = false
  //    facebookLoginButton.isEnabled = false
  //
  //    // cancel previous API call
  //    apiTask?.cancel()
  //
  //    // create a new API call
  //    apiTask = PhoneService.startVerification(forPhoneNumber: phoneNumber, countryCode: countryCode, completion: { [weak self] (error) in
  //      DispatchQueue.main.async {
  //        // reset UI
  //        self?.phoneNumberVerifyButton.isEnabled = true
  //        self?.phoneNumberTextField.isEnabled = true
  //        self?.phoneNumberVerifyButton.isEnabled = true
  //        self?.facebookLoginButton.isEnabled = true
  //
  //
  //        if let error = error {
  //          self?.alertError(error)
  //        } else {
  //          self?.performSegue(withIdentifier: R.segue.signInViewController.showVerifyCode.identifier, sender: nil)
  //          self?.phoneNumberTextField.text = ""
  //        }
  //      }
  //    })
  //  }
  
  @IBAction func unwindToSignIn(_ unwindSegue: UIStoryboardSegue) {
    if unwindSegue.source is SettingsTableViewController {
      fbLoginResult = nil
    }
  }
  
  
  // MARK: - private
  
  private func setupUI() {
    view.backgroundColor = UIColor.primaryRedColor
    
    
    if let constraint = facebookLoginButton.constraints.first(where: { (constraint) -> Bool in
      return constraint.firstAttribute == .height
    }) {
      constraint.constant = 40.0
    }
    
    facebookLoginButton.readPermissions = ["public_profile", "email"]
    facebookLoginButton.delegate = self
  }
  
  override func viewDidLayoutSubviews() {
    backdropView.layoutCornerRadiusMask(corners: [.topLeft, .topRight])
  }
  
  private func authenticateWithFacebook(result: FBSDKLoginManagerLoginResult) {
    // cancel previous API call
    apiTask?.cancel()
    
    // create a new API call
    showLoading()
    apiTask = AuthService.login(withFacebookToken: result.token.tokenString, completion: { [weak self] (error) in
      
      DispatchQueue.main.async {
        guard error == nil else {
          self?.flashErrorMessage(error?.localizedDescription)
          return
        }
        
        if Defaults[.userOnboarded] {
          self?.dismissLoading()
          self?.performSegue(withIdentifier: R.segue.signInViewController.showHome, sender: self)
        }
        else {
          self?.dismissLoading()
          self?.performSegue(withIdentifier: R.segue.signInViewController.showOnboard, sender: self)
        }
      }
    })
  }
}


extension SignInViewController: FBSDKLoginButtonDelegate {
  func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
    guard error == nil else {
      logger.warning("Facebook error: \(error.localizedDescription)")
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
