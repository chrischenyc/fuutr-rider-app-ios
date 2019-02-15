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
    
    emailTextField.delegate = self
    validate()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    KeyboardAvoiding.avoidingView = stackView
    emailTextField.becomeFirstResponder()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let signInPasswordViewController = segue.destination as? EmailSignInPasswordViewController,
      let displayName = sender as? String? {
      
      signInPasswordViewController.email = emailTextField.text
      signInPasswordViewController.displayName = displayName
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
        
        // TODO: image
        self?.alertMessage(title: "Check your email!",
                           message: "We sent you a verification code",
                           image: nil, // R.image.icCheckDarkGray16(),
          positiveActionButtonTitle: "Continue",
          positiveActionButtonTapped: {
            // TODO: segue
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
