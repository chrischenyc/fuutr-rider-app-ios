//
//  ResetPasswordRequestViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 12/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding

class ResetPasswordRequestViewController: UIViewController {
  
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var submitButton: UIButton!
  
  private var apiTask: URLSessionTask?
  var email: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyTheme()
    
    emailTextField.text = email
    
    validate()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    KeyboardAvoiding.avoidingView = stackView
    emailTextField.becomeFirstResponder()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let verifyCodeViewController = segue.destination as? ResetPasswordVerifyViewController {
      verifyCodeViewController.email = emailTextField.text
    }
  }
  
  @IBAction func emailChanged(_ sender: Any) {
    validate()
  }
  
  @IBAction func submitButtonTapped(_ sender: Any) {
    guard let email = emailTextField.text else { return }
    
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
                           message: "We sent you a password reset code",
                           image: nil, // R.image.icCheckDarkGray16(),
                           positiveActionButtonTitle: "Continue",
                           positiveActionButtonTapped: {
                            self?.performSegue(withIdentifier: R.segue.resetPasswordRequestViewController.showVerifyCode, sender: nil)
        })
      }
    })
  }
  
  private func validate() {
    guard let email = emailTextField.text else {
      submitButton.isEnabled = false
      return
    }
    
    submitButton.isEnabled = email.isEmail()
  }
  
}
