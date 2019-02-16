//
//  UpdateEmailRequestViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 9/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding

class UpdateEmailRequestViewController: UIViewController {
  
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var nextButton: UIButton!
  
  private var authAPITask: URLSessionTask?
  
  // MARK: - lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyLightTheme()
    emailTextField.delegate = self
    validate()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    KeyboardAvoiding.avoidingView = stackView
    emailTextField.becomeFirstResponder()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let updateEmailVerifyViewController = segue.destination as? UpdateEmailVerifyViewController {
      updateEmailVerifyViewController.email = emailTextField.text
    }
  }
  
  // MARK: - user actions
  
  @IBAction func emailChanged(_ sender: Any) {
    validate()
  }
  
  @IBAction func nextTapped(_ sender: Any) {
    guard let email = emailTextField.text else {
      return
    }
    
    showLoading()
    
    authAPITask?.cancel()
    
    authAPITask = AuthService.requestUpdateEmailCode(to: email, completion: { [weak self] (error) in
      
      DispatchQueue.main.async {
        
        self?.dismissLoading()
        
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        self?.alertMessage(title: "Check your email!",
                           message: "We sent a verification code to \(email)",
                           image: R.image.imgSuccessCheck(),
          positiveActionButtonTitle: "Continue",
          positiveActionButtonTapped: {
            self?.performSegue(withIdentifier: R.segue.updateEmailRequestViewController.showVerifyCode, sender: nil)
        })
      }
    })
  }
  
  // MARK: - private
  private func validate() {
    guard let validEmail = emailTextField.text?.isEmail(), validEmail == true else {
      nextButton.isEnabled = false
      return
    }
    
    nextButton.isEnabled = true
  }
  
}


extension UpdateEmailRequestViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    nextTapped(textField)
    
    return true
  }
}
