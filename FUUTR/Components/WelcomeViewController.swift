//
//  WelcomeViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 31/10/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SwiftyUserDefaults

class WelcomeViewController: UIViewController {
  
  @IBOutlet weak var backdropView: UIView!
  @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
  
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
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  
  // MARK: - user actions
  
  @IBAction func unwindToWelcome(_ unwindSegue: UIStoryboardSegue) {
    if unwindSegue.source is AccountViewController {
      fbLoginResult = nil
    }
  }
  
  @IBAction func onAgreement(_ sender: Any) {
    if let url = URL(string: config.env.termsURL), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
  
  @IBAction func onPrivacy(_ sender: Any) {
    if let url = URL(string: config.env.privacyURL), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
    backdropView.layoutCornerRadiusMask(corners: [.layerMinXMinYCorner, .layerMinXMaxYCorner])
  }
  
  private func authenticateWithFacebook(result: FBSDKLoginManagerLoginResult) {
    // cancel previous API call
    apiTask?.cancel()
    
    // create a new API call
    showLoading()
    apiTask = AuthService.login(withFacebookToken: result.token.tokenString, completion: { [weak self] (error) in
      
      DispatchQueue.main.async {
        self?.dismissLoading()
        
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        self?.performSegue(withIdentifier: R.segue.welcomeViewController.showMain, sender: self)
      }
    })
  }
}


extension WelcomeViewController: FBSDKLoginButtonDelegate {
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
