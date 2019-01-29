//
//  ResetPasswordVerifyViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 12/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit

class ResetPasswordVerifyViewController: UIViewController {
  
  @IBOutlet weak var codeTextField: UITextField!
  @IBOutlet weak var submitButton: UIButton!
  @IBOutlet weak var resendButton: UIButton!
  
  private var apiTask: URLSessionTask?
  var email: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    codeTextField.becomeFirstResponder()
    submitButton.isEnabled = false
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let setPasswordViewController = segue.destination as? ResetPasswordSetViewController {
      setPasswordViewController.email = email
      setPasswordViewController.code = codeTextField.text
    }
  }
  
  @IBAction func codeChanged(_ sender: Any) {
    guard email != nil, let code = codeTextField.text else {
      submitButton.isEnabled = false
      return
    }
    
    submitButton.isEnabled = code.isFourDigits()
  }
  
  @IBAction func submitButtonTapped(_ sender: Any) {
    guard let email = email, let code = codeTextField.text else { return }
    
    apiTask?.cancel()
    
    showLoading()
    apiTask = AuthService.verifyPasswordResetCode(forEmail: email, code: code, completion: { [weak self] (error) in
      DispatchQueue.main.async {
        guard error == nil else {
          self?.flashErrorMessage(error?.localizedDescription)
          return
        }
        
        self?.flashSuccessMessage("Code looks good!", completion: { (finished) in
          self?.perform(segue: StoryboardSegue.SignIn.fromResetPasswordVerifyCodeToSetPassword)
        })
      }
    })
  }
  
  @IBAction func resendButtonTapped(_ sender: Any) {
    guard let email = email else { return }
    
    apiTask?.cancel()
    
    showLoading()
    apiTask = AuthService.requestPasswordResetCode(forEmail: email, completion: { [weak self] (error) in
      DispatchQueue.main.async {
        guard error == nil else {
          self?.flashErrorMessage(error?.localizedDescription)
          return
        }
        
        self?.flashSuccessMessage("Code sent, please check your email", completion: { (finished) in
          self?.codeTextField.becomeFirstResponder()
        })
      }
    })
  }
  
}
