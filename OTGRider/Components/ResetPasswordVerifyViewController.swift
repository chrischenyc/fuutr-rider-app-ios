//
//  ResetPasswordVerifyViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 12/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding

class ResetPasswordVerifyViewController: UIViewController {
  
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var codeTextField: UITextField!
  @IBOutlet weak var submitButton: UIButton!
  @IBOutlet weak var resendButton: UIButton!
  
  private var apiTask: URLSessionTask?
  var email: String?
  
  
  // lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    validate()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    KeyboardAvoiding.avoidingView = stackView
    codeTextField.becomeFirstResponder()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let setPasswordViewController = segue.destination as? ResetPasswordSetViewController {
      setPasswordViewController.email = email
      setPasswordViewController.code = codeTextField.text
    }
  }
  
  @IBAction func unwindToResetPasswordVerify(_ unwindSegue: UIStoryboardSegue) {
    
  }
  
  // MARK: - user actions
  @IBAction func codeChanged(_ sender: Any) {
    validate()
  }
  
  @IBAction func submitButtonTapped(_ sender: Any) {
    guard let email = email, let code = codeTextField.text else { return }
    
    apiTask?.cancel()
    
    showLoading()
    apiTask = AuthService.verifyPasswordResetCode(forEmail: email, code: code, completion: { [weak self] (error) in
      DispatchQueue.main.async {
        self?.dismissLoading()
        
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        self?.performSegue(withIdentifier: R.segue.resetPasswordVerifyViewController.showSetPassword, sender: nil)
      }
    })
  }
  
  @IBAction func resendButtonTapped(_ sender: Any) {
    guard let email = email else { return }
    
    apiTask?.cancel()
    
    showLoading()
    
    apiTask = AuthService.requestPasswordResetCode(forEmail: email, completion: { [weak self] (error) in
      DispatchQueue.main.async {
        self?.dismissLoading()
        
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        // TODO: image
        self?.alertMessage(title: "Check your email!",
                           message: "We sent you a password reset code")
      }
    })
  }
  
  // MARK: - private
  
  private func validate() {
    guard email != nil, let code = codeTextField.text else {
      submitButton.isEnabled = false
      return
    }
    
    submitButton.isEnabled = code.isFourDigits()
  }
  
}
