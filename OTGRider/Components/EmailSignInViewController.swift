//
//  EmailSignInViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 6/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding

class EmailSignInViewController: UIViewController {
  
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
    if let signInPasswordViewController = segue.destination as? EmailSignInPasswordViewController,
      let displayName = sender as? String? {
      
      signInPasswordViewController.email = emailTextField.text
      signInPasswordViewController.displayName = displayName
    }
  }
  
  // MARK: - user actions
  
  @IBAction func unwindToSignInEmail(_ unwindSegue: UIStoryboardSegue) {
    
  }
  
  @IBAction func emailChanged(_ sender: Any) {
    validate()
  }
  
  @IBAction func nextTapped(_ sender: Any) {
    guard let email = emailTextField.text else {
      return
    }
    
    showLoading()
    
    authAPITask?.cancel()
    
    authAPITask = AuthService.verify(email: email, completion: { [weak self] (displayName, error) in
      
      DispatchQueue.main.async {
        
        self?.dismissLoading()
        
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        self?.performSegue(withIdentifier: R.segue.emailSignInViewController.showEnterPassword, sender: displayName)
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


extension EmailSignInViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    nextTapped(textField)
    
    return true
  }
}
