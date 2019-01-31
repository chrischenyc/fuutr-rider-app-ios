//
//  ResetPasswordRequestViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 12/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit

class ResetPasswordRequestViewController: UIViewController {
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var submitButton: UIButton!
  
  private var apiTask: URLSessionTask?
  var email: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    emailTextField.becomeFirstResponder()
    emailTextField.text = email
    validateInput()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let verifyCodeViewController = segue.destination as? ResetPasswordVerifyViewController {
      verifyCodeViewController.email = emailTextField.text
    }
  }
  
  @IBAction func emailChanged(_ sender: Any) {
    validateInput()
  }
  
  @IBAction func submitButtonTapped(_ sender: Any) {
    guard let email = emailTextField.text else { return }
    
    apiTask?.cancel()
    
    showLoading()
    apiTask = AuthService.requestPasswordResetCode(forEmail: email, completion: { [weak self] (error) in
      DispatchQueue.main.async {
        guard error == nil else {
          self?.flashErrorMessage(error?.localizedDescription)
          return
        }
        
        self?.flashSuccessMessage("Code sent, please check your email", completion: { (finished) in
          self?.performSegue(withIdentifier: R.segue.resetPasswordRequestViewController.showVerifyCode, sender: nil)
        })
      }
    })
  }
  
  private func validateInput() {
    guard let email = emailTextField.text else {
      submitButton.isEnabled = false
      return
    }
    
    submitButton.isEnabled = email.isEmail()
  }
  
}
