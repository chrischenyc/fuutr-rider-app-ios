//
//  ResetPasswordSetViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 12/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding

class ResetPasswordSetViewController: UIViewController {
  
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var showPasswordButton: UIButton!
  @IBOutlet weak var submitButton: UIButton!
  
  private var apiTask: URLSessionTask?
  var email: String?
  var code: String?
  
  // MARK: - lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    passwordTextField.delegate = self
    
    validate()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    KeyboardAvoiding.avoidingView = stackView
    passwordTextField.becomeFirstResponder()
  }
  
  // MARK: - user actions
  
  @IBAction func toggleShowPassword(_ sender: Any) {
    passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
    
    if passwordTextField.isSecureTextEntry {
      showPasswordButton.setImage(R.image.icShowDarkGray16(), for: .normal)
    } else {
      showPasswordButton.setImage(R.image.icHideDarkGray16(), for: .normal)
    }
  }
  
  @IBAction func passwordChanged(_ sender: Any) {
    validate()
  }
  
  @IBAction func submitButtonTapped(_ sender: Any) {
    guard let email = email,
      let code = code,
      let password = passwordTextField.text,
      password.isValidPassword() else { return }
    
    apiTask?.cancel()
    
    showLoading()
    
    apiTask = AuthService.resetPassword(forEmail: email, code: code, password: password ,completion: { [weak self] (error) in
      DispatchQueue.main.async {
        self?.dismissLoading()
        
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        
        self?.alertMessage(title: "Done!",
                           message: "Please log in with the new password",
                           image: nil,
                           hapticFeedbackType: .success,
                           positiveActionButtonTitle: "Log in",
                           positiveActionButtonTapped: {
                            self?.performSegue(withIdentifier: R.segue.resetPasswordSetViewController.unwindToSignInPassword, sender: nil)
        })
      }
    })
  }
  
  // MARK: - private
  private func validate() {
    guard email != nil, code != nil, let password = passwordTextField.text else {
      submitButton.isEnabled = false
      return
    }
    
    submitButton.isEnabled = password.isValidPassword()
  }
}

extension ResetPasswordSetViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    submitButtonTapped(textField)
    
    return true
  }
}
