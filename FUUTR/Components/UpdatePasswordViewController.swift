//
//  UpdatePasswordViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 15/02/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding

class UpdatePasswordViewController: UIViewController {
  
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var currentPasswordStackView: UIStackView!
  @IBOutlet weak var currentPasswordTextField: UITextField!
  @IBOutlet weak var newPasswordTextField: UITextField!
  @IBOutlet weak var showCurrentPasswordButton: UIButton!
  @IBOutlet weak var showNewPasswordButton: UIButton!
  @IBOutlet weak var submitButton: UIButton!
  
  private var apiTask: URLSessionTask?
  var hasPassword: Bool = true
  
  // MARK: - lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyLightTheme()
    
    currentPasswordTextField.delegate = self
    newPasswordTextField.delegate = self
    
    // if user doesn't have a password, meaning Mobile or Facebook sign up
    // we only has for new password
    if !hasPassword {
      stackView.removeArrangedSubview(currentPasswordStackView)
      currentPasswordStackView.removeFromSuperview()
    }
    
    validate()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    KeyboardAvoiding.avoidingView = stackView
    
    if hasPassword {
      currentPasswordTextField.becomeFirstResponder()
    }
    else {
      newPasswordTextField.becomeFirstResponder()
    }
  }
  
  // MARK: - user actions
  
  @IBAction func toggleShowPassword(_ sender: Any) {
    guard let button = sender as? UIButton else { return }
    
    var passwordTextField: UITextField?
    if button == showCurrentPasswordButton {
      passwordTextField = currentPasswordTextField
    }
    else if button == showNewPasswordButton {
      passwordTextField = newPasswordTextField
    }
    
    if let passwordTextField = passwordTextField {
      passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
      
      if passwordTextField.isSecureTextEntry {
        button.setImage(R.image.icShowDarkGray16(), for: .normal)
      } else {
        button.setImage(R.image.icHideDarkGray16(), for: .normal)
      }
    }
  }
  
  @IBAction func passwordChanged(_ sender: Any) {
    validate()
  }
  
  @IBAction func submitButtonTapped(_ sender: Any) {
    var currentPassword: String?
    if hasPassword {
      currentPassword = currentPasswordTextField.text
      if hasPassword {
        guard let currentPassword = currentPassword, currentPassword.isValidPassword() else { return }
      }
    }
    
    guard let newPassword = newPasswordTextField.text, newPassword.isValidPassword() else { return }
    
    apiTask?.cancel()
    
    showLoading()
    
    apiTask = AuthService.updatePassword(currentPassword: currentPassword,
                                         newPassword: newPassword,
                                         completion: { [weak self] (error) in
                                          DispatchQueue.main.async {
                                            self?.dismissLoading()
                                            
                                            guard error == nil else {
                                              self?.alertError(error!)
                                              return
                                            }
                                            
                                            
                                            self?.alertMessage(title: "Done!",
                                                               message: nil,
                                                               image: nil,
                                                               positiveActionButtonTapped: {
                                                                self?.performSegue(withIdentifier: R.segue.updatePasswordViewController.unwindToSettings, sender: nil)
                                            })
                                          }
    })
  }
  
  // MARK: - private
  private func validate() {
    if hasPassword {
      let currentPassword = currentPasswordTextField.text
      if hasPassword {
        guard let currentPassword = currentPassword, currentPassword.isValidPassword() else {
          submitButton.isEnabled = false
          return
        }
      }
    }
    
    guard let newPassword = newPasswordTextField.text, newPassword.isValidPassword() else {
      submitButton.isEnabled = false
      return
    }
    
    submitButton.isEnabled = true
  }
}

extension UpdatePasswordViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == currentPasswordTextField {
      newPasswordTextField.becomeFirstResponder()
    }
    else {
      submitButtonTapped(textField)
    }
    
    return true
  }
}
