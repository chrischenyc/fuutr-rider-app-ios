//
//  ResetPasswordSetViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 12/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit

class ResetPasswordSetViewController: UIViewController {
  
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var submitButton: UIButton!
  
  private var apiTask: URLSessionTask?
  var email: String?
  var code: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    passwordTextField.becomeFirstResponder()
    submitButton.isEnabled = false
  }
  
  @IBAction func passwordChanged(_ sender: Any) {
    guard email != nil, code != nil, let password = passwordTextField.text else {
      submitButton.isEnabled = false
      return
    }
    
    submitButton.isEnabled = password.isValidPassword()
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
        guard error == nil else {
          self?.flashErrorMessage(error?.localizedDescription)
          return
        }
        
        self?.flashSuccessMessage("Done! Please log in with the new password", completion: { (finished) in
          if finished {
            self?.performSegue(withIdentifier: R.segue.resetPasswordSetViewController.fromSetNewPasswordToLogin.identifier, sender: nil)
          }
        })
      }
    })
  }
  
}
