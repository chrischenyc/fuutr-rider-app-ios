//
//  EmailSignInViewController.swift
//  OTGRider
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
  
  // MARK: - lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.tintColor = UIColor.primaryDarkColor
    navigationController?.navigationBar.largeTitleTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.primaryDarkColor
    ]
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
    
    validate()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    KeyboardAvoiding.avoidingView = stackView
    emailTextField.becomeFirstResponder()
  }
  
  // MARK: - user actions
  
  @IBAction func emailChanged(_ sender: Any) {
    validate()
  }
  
  @IBAction func nextTapped(_ sender: Any) {
    showLoading()
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
