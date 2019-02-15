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
import IHKeyboardAvoiding

class AccountViewController: UIViewController {
  
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var avatarEditButton: UIButton!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var emailButton: UIButton!
  @IBOutlet weak var phoneTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  private var apiTask: URLSessionTask?
  private var user: User? {
    didSet {
      toggleEditing(false)
      
      if let user = user {
        populateUserProfile(user, editing: false)
      }
    }
  }
  
  // MARK: - lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyLightTheme()
    
    toggleEditing(false)
    loadProfile()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    KeyboardAvoiding.avoidingView = stackView
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    
    // needed to clear the text in the back navigation:
    self.navigationItem.title = " "
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationItem.title = "Account"
  }
  
  override func viewDidLayoutSubviews() {
    avatarImageView.layoutCornerRadiusMask(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadius: avatarImageView.frame.size.width/2)
    
    avatarEditButton.layoutCornerRadiusMask(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadius: avatarEditButton.frame.size.width/2)
  }
  
  // MARK: - user actions
  
  @IBAction func unwindToSettings(_ unwindSegue: UIStoryboardSegue) {
    loadProfile()
  }
  
  @objc func unwindToHome() {
    performSegue(withIdentifier: R.segue.accountViewController.unwindToHome, sender: nil)
  }
  
  @objc func cancelEditing() {
    toggleEditing(false)
  }
  
  @objc func startEditing() {
    toggleEditing(true)
  }
  
  @objc func saveEditing() {
    var profile: JSON = [:]
    profile["displayName"] = nameTextField.text
    
    apiTask?.cancel()
    
    showLoading()
    
    apiTask = UserService.updateProfile(profile, completion: { [weak self] (error) in
      DispatchQueue.main.async {
        
        self?.dismissLoading()
        
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        self?.loadProfile()
      }
    })
  }
  
  @IBAction func editAvatar(_ sender: Any) {
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
    if let editPhoneViewController = segue.destination as? EditPhoneViewController {
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
        
        self?.user = user
      }
    })
  }
  
  // MARK: - private
  private func toggleEditing(_ on: Bool) {
    if on {
      navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                         target: self,
                                                         action: #selector(cancelEditing))
      
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                          target: self,
                                                          action: #selector(saveEditing))
      
      nameTextField.isEnabled = true
      emailButton.isEnabled = true
      phoneTextField.isEnabled = false
      passwordTextField.isEnabled = true
      
      avatarEditButton.isHidden = false
    } else {
      navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.icCloseDarkGray16(),
                                                         style: .plain,
                                                         target: self,
                                                         action: #selector(unwindToHome))
      
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                          target: self,
                                                          action: #selector(startEditing))
      
      nameTextField.isEnabled = false
      emailButton.isEnabled = false
      phoneTextField.isEnabled = false
      passwordTextField.isEnabled = false
      
      avatarEditButton.isHidden = true
    }
    
    if let user = user {
      populateUserProfile(user, editing: on)
    }
  }
  
  private func populateUserProfile(_ user: User, editing: Bool) {
    if editing {
      nameTextField.textColor = UIColor.primaryDarkColor
      nameTextField.placeholder = "e.g. Charlotte Johnston"
      nameTextField.text = user.displayName
      
      emailButton.setTitleColor(UIColor.primaryGreyColor, for: .normal)
      if let email = user.email, email.count > 0 {
        emailButton.setTitleColor(UIColor.primaryGreyColor, for: .normal)
        emailButton.setTitle(email, for: .normal)
      }
      else {
        emailButton.setTitleColor(UIColor.primaryGreyColor, for: .normal)
        emailButton.setTitle("email", for: .normal)
      }
      
      phoneTextField.textColor = UIColor.primaryDarkColor
      phoneTextField.placeholder = "0412 345 678"
      phoneTextField.text = user.phoneNumber
      
      passwordTextField.textColor = UIColor.primaryDarkColor
      passwordTextField.placeholder = "Current password"
      passwordTextField.text = ""
    } else {
      if let displayName = user.displayName, displayName.count > 0 {
        nameTextField.textColor = UIColor.primaryGreyColor
        nameTextField.text = displayName
      }
      else {
        nameTextField.textColor = UIColor.primaryRedColor
        nameTextField.text = "+ Add your name"
      }
      
      if let email = user.email, email.count > 0 {
        emailButton.setTitleColor(UIColor.primaryGreyColor, for: .normal)
        emailButton.setTitle(email, for: .normal)
      }
      else {
        emailButton.setTitleColor(UIColor.primaryRedColor, for: .normal)
        emailButton.setTitle("+ Add an email", for: .normal)
      }
      
      if let phone = user.phoneNumber, phone.count > 0 {
        phoneTextField.textColor = UIColor.primaryGreyColor
        phoneTextField.text = phone
      }
      else {
        phoneTextField.textColor = UIColor.primaryRedColor
        phoneTextField.text = "+ Add a phone"
      }
      
      if let hasPassword = user.hasPassword, hasPassword {
        passwordTextField.textColor = UIColor.primaryGreyColor
        passwordTextField.text = "password"
        passwordTextField.isSecureTextEntry = true
      }
      else {
        passwordTextField.textColor = UIColor.primaryRedColor
        passwordTextField.text = "+ Add a password"
        passwordTextField.isSecureTextEntry = false
      }
    }
  }
}