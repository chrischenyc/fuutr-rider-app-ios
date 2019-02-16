//
//  MobileRequestCodeViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 7/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding
import FlagPhoneNumber

enum MobileVerifyAction {
  case signIn       // this screen is segued from email sign in
  case updatePhone  // this screen is segued fom change phone number
}

class MobileRequestCodeViewController: UIViewController {
  
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var phoneNumberTextField: FPNTextField!
  @IBOutlet weak var nextButton: UIButton!
  
  private var authAPITask: URLSessionTask?
  private var countryCode: UInt64?
  private var phoneNumber: String?
  
  var action: MobileVerifyAction = .signIn
  
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
    if let mobileVerifyCodeViewController = segue.destination as? MobileVerifyCodeViewController {
      guard let countryCode = countryCode, let phoneNumber = phoneNumber else { return }
      
      mobileVerifyCodeViewController.action = action
      mobileVerifyCodeViewController.countryCode = countryCode
      mobileVerifyCodeViewController.phoneNumber = phoneNumber
    }
  }
  
  // MARK: - user actions
  
  @IBAction func closeTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
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
        
        self?.performSegue(withIdentifier: R.segue.mobileRequestCodeViewController.showVerifyCode, sender: nil)
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

extension MobileRequestCodeViewController: FPNTextFieldDelegate {
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
