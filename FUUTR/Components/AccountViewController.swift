//
//  AccountViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 1/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import FBSDKLoginKit

class AccountViewController: UIViewController {
  
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var phoneTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  private var apiTask: URLSessionTask?
  private var user: User?
  
  // MARK: - lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyLightTheme()
    
    nameTextField.isEnabled = false
    nameTextField.textColor = UIColor.primaryGreyColor
    emailTextField.isEnabled = false
    emailTextField.textColor = UIColor.primaryGreyColor
    phoneTextField.isEnabled = false
    phoneTextField.textColor = UIColor.primaryGreyColor
    passwordTextField.isEnabled = false
    passwordTextField.textColor = UIColor.primaryGreyColor
    
    loadProfile()
  }
  
  override func viewDidLayoutSubviews() {
    avatarImageView.layoutCornerRadiusMask(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadius: avatarImageView.frame.size.width/2)
  }
  
  // MARK: - user actions
  
  @IBAction func unwindToSettings(_ unwindSegue: UIStoryboardSegue) {
    loadProfile()
  }
  
  @IBAction func signOut() {
    _ = AuthService.logout { (error) in
      guard error == nil else {
        logger.error(error?.localizedDescription)
        return
      }
    }
    
    Defaults[.userSignedIn] = false
    Defaults[.accessToken] = ""
    Defaults[.refreshToken] = ""
    if FBSDKAccessToken.current() != nil {
      FBSDKLoginManager().logOut()
    }
    
    NotificationCenter.default.post(name: .userSignedOut, object: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let editNameViewController = segue.destination as? EditNameViewController {
      editNameViewController.displayName = user?.displayName
    }
    else if let editEmailViewController = segue.destination as? EditEmailViewController {
      editEmailViewController.email = user?.email
    }
    else if let editPhoneViewController = segue.destination as? EditPhoneViewController {
      editPhoneViewController.countryCode = user?.countryCode
      editPhoneViewController.phoneNumber = user?.phoneNumber
    }
  }
  
  // MARK: - API
  private func loadProfile() {
    apiTask?.cancel()
    
    showLoading()
    
    apiTask = UserService.getProfile({[weak self] (user, error) in
      DispatchQueue.main.async {
        self?.dismissLoading()
        
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        guard let user = user else {
          self?.alertMessage(message: R.string.localizable.kOtherError())
          return
        }
        
        self?.nameTextField.text = user.displayName
        self?.emailTextField.text = user.email
        self?.phoneTextField.text = user.phoneNumber
        self?.passwordTextField.text = "password"
        self?.user = user
      }
    })
  }
}
