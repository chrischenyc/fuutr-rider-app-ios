//
//  EmailAuthViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 6/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class EmailAuthViewController: UIViewController {
  
  private enum EmailAuthType {
    case signUp
    case logIn
  }
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var submitButton: UIButton!
  
  private var authType: EmailAuthType = .signUp
  private var apiTask: URLSessionDataTask?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    emailTextField.becomeFirstResponder()
    submitButton.isEnabled = false
    submitButton.layoutCornerRadiusAndShadow()
    submitButton.backgroundColor = UIColor.primaryWhiteColor
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == R.segue.emailAuthViewController.fromSignUpToLogIn.identifier {
      if let emailAuthViewController = segue.destination as? EmailAuthViewController {
        emailAuthViewController.authType = .logIn
      }
    }
    else if let resetPasswordRequestViewController = segue.destination as? ResetPasswordRequestViewController {
      resetPasswordRequestViewController.email = emailTextField.text
    }
  }
  
  @IBAction func unwindToEmailAuth(_ unwindSegue: UIStoryboardSegue) {
    if let resetPasswordSetViewController = unwindSegue.source as? ResetPasswordSetViewController {
      emailTextField.text = resetPasswordSetViewController.email
      passwordTextField.text = ""
    }
  }
  
  @IBAction func unwindToEmailSignUp(_ unwindSegue: UIStoryboardSegue) {
    authType = .signUp
  }
  
  @IBAction func emailChanged(_ sender: Any) {
    validateInput()
  }
  
  @IBAction func passwordChanged(_ sender: Any) {
    validateInput()
  }
  
  @IBAction func submitTapped(_ sender: Any) {
    guard let email = emailTextField.text else { return }
    guard let passowrd = passwordTextField.text else { return }
    
    // cancel previous API call
    apiTask?.cancel()
    
    // create a new API call
    showLoading()
    
    if authType == .signUp {
      apiTask = AuthService.signup(withEmail: email, password: passowrd, completion: { [weak self] (error) in
        self?.handleAuthCompletion(error)
      })
    } else {
      apiTask = AuthService.login(withEmail: email, password: passowrd, completion: {[weak self] (error) in
        self?.handleAuthCompletion(error)
      })
    }
  }
  
  private func validateInput() {
    guard let validEmail = emailTextField.text?.isEmail(), validEmail == true else {
      submitButton.isEnabled = false
      return
    }
    
    guard let validPassword = passwordTextField.text?.isValidPassword(), validPassword == true else {
      submitButton.isEnabled = false
      return
    }
    
    submitButton.isEnabled = true
  }
  
  private func handleAuthCompletion(_ error: Error?) {
    DispatchQueue.main.async {
      guard error == nil else {
        self.flashErrorMessage(error?.localizedDescription)
        return
      }
      
      self.dismissLoading()
      if Defaults[.userOnboarded] {
        self.performSegue(withIdentifier: self.authType == .signUp ?
          R.segue.emailAuthViewController.fromEmailSignUpToMain.identifier :
          R.segue.emailAuthViewController.fromEmailLogInToMain.identifier, sender: nil)
      }
      else {
        self.performSegue(withIdentifier: self.authType == .signUp ?
          R.segue.emailAuthViewController.fromEmailSignUpToOnboard.identifier :
          R.segue.emailAuthViewController.fromEmailLogInToOnboard.identifier, sender: nil)
      }
    }
  }
}
