//
//  MobileSignInViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 7/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding
import FlagPhoneNumber

class MobileSignInViewController: UIViewController {
  
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var phoneNumberTextField: FPNTextField!
  @IBOutlet weak var nextButton: UIButton!
  
  private var authAPITask: URLSessionTask?
  private var countryCode: UInt64?
  private var phoneNumber: String?
  
  // MARK: - lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    KeyboardAvoiding.avoidingView = stackView
    phoneNumberTextField.becomeFirstResponder()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let navigationController = segue.destination as? UINavigationController,
      let mobileVerifyCodeViewController = navigationController.topViewController as? MobileVerifyViewController {
      guard let countryCode = countryCode, let phoneNumber = phoneNumber else { return }
      
      mobileVerifyCodeViewController.countryCode = countryCode
      mobileVerifyCodeViewController.phoneNumber = phoneNumber
    }
  }
  
  // MARK: - user actions
  
  @IBAction func unwindToSignInMobile(_ unwindSegue: UIStoryboardSegue) {
    
  }
  
  @IBAction func nextTapped(_ sender: Any) {
    guard let phoneNumber = phoneNumber, let countryCode = countryCode else { return }
    
    authAPITask?.cancel()
    
    showLoading()
    
    authAPITask = PhoneService.startVerification(forPhoneNumber: phoneNumber, countryCode: countryCode, completion: { [weak self] (error) in
      
      DispatchQueue.main.async {
        self?.dismissLoading()
        
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        self?.performSegue(withIdentifier: R.segue.mobileSignInViewController.showVerifyCode, sender: nil)
      }
    })
  }
  
  // MARK: - private
  private func setupUI() {
    navigationController?.navigationBar.applyLightTheme()
    phoneNumberTextField.setFlag(for: .AU)
    countryCode = 61
    phoneNumberTextField.parentViewController = self
    phoneNumberTextField.delegate = self
    phoneNumberTextField.flagSize = CGSize(width: 24, height: 24)
    phoneNumberTextField.flagButtonEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 16)
    phoneNumberTextField.placeholder = "0412 345 678"
    nextButton.isEnabled = false
  }
  
}

extension MobileSignInViewController: FPNTextFieldDelegate {
  func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
    countryCode = UInt64(dialCode.replacingOccurrences(of: "+", with: ""))
  }
  
  func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
    if isValid {
      phoneNumber = textField.getRawPhoneNumber()
    } else {
      phoneNumber = nil
    }
    
    nextButton.isEnabled = isValid
  }
}
