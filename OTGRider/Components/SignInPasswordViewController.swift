//
//  SignInPasswordViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 7/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding
import SwiftyUserDefaults

class SignInPasswordViewController: UIViewController {
  
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var showPasswordButton: UIButton!
  @IBOutlet weak var submitButton: UIButton!
  
  private var authAPITask: URLSessionTask?
  var email: String?
  var displayName: String?  // if it has value, it's a sign in case; otherwise, sign up
  
  // MARK: - lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyTheme()
    if let displayName = displayName {
      title = "G'day, \(displayName)!"
      submitButton.setTitle("Log in", for: .normal)
    }
    else {
      title = "G'day!"
      submitButton.setTitle("Sign up", for: .normal)
    }
    
    validate()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    KeyboardAvoiding.avoidingView = stackView
    passwordTextField.becomeFirstResponder()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let resetPasswordRequestViewController = segue.destination as? ResetPasswordRequestViewController {
      resetPasswordRequestViewController.email = email
    }
  }
  
  // MARK: - user actions
  
  @IBAction func unwindToSignInPassword(_ unwindSegue: UIStoryboardSegue) {
    
  }
  
  @IBAction func passwordChanged(_ sender: Any) {
    validate()
  }
  
  @IBAction func toggleShowPassword(_ sender: Any) {
    passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
    
    if passwordTextField.isSecureTextEntry {
      showPasswordButton.setImage(R.image.icShowDarkGray16(), for: .normal)
    } else {
      showPasswordButton.setImage(R.image.icHideDarkGray16(), for: .normal)
    }
  }
  
  @IBAction func submitTapped(_ sender: Any) {
    guard let email = email, let password = passwordTextField.text else {
      return
    }
    
    showLoading()
    
    authAPITask?.cancel()
    
    if displayName == nil {
      authAPITask = AuthService.signup(withEmail: email, password: password, completion: { [weak self] (error) in
        DispatchQueue.main.async {
          self?.dismissLoading()
          self?.handleAuthCompletion(error)
        }
      })
    } else {
      authAPITask = AuthService.login(withEmail: email, password: password, completion: {[weak self] (error) in
        DispatchQueue.main.async {
          self?.dismissLoading()
          self?.handleAuthCompletion(error)
        }
      })
    }
  }
  
  // MARK: - private
  private func validate() {
    guard let password = passwordTextField.text, password.count > 0 else {
      submitButton.isEnabled = false
      return
    }
    
    submitButton.isEnabled = password.isValidPassword()
  }
  
  private func handleAuthCompletion(_ error: Error?) {
    guard error == nil else {
      alertError(error!)
      return
    }
    
    if Defaults[.userOnboarded] {
      performSegue(withIdentifier: R.segue.signInPasswordViewController.showMap, sender: nil)
    }
    else {
      performSegue(withIdentifier: R.segue.signInPasswordViewController.showOnboard, sender: nil)
    }
  }
}
