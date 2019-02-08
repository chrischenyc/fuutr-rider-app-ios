//
//  SignInMobileViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 7/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding

class SignInMobileViewController: UIViewController {
  
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var phoneNumberTextField: UITextField!
  @IBOutlet weak var nextButton: UIButton!
  
  private var authAPITask: URLSessionTask?
  private var countryCode: UInt64?
  private var phoneNumber: String?
  
  // MARK: - lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyTheme()
//    validate()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    KeyboardAvoiding.avoidingView = stackView
    phoneNumberTextField.becomeFirstResponder()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let verifyCodeViewController = segue.destination as? MobileVerifyCodeViewController {
      guard let countryCode = countryCode, let phoneNumber = phoneNumber else { return }
      
      verifyCodeViewController.countryCode = countryCode
      verifyCodeViewController.phoneNumber = phoneNumber
    }
  }
  
  // MARK: - user actions
  
  @IBAction func unwindToSignInMobile(_ unwindSegue: UIStoryboardSegue) {
    
  }
  
  @IBAction func phoneNumberChanged(_ sender: Any) {
    validate()
  }
  
  @IBAction func nextTapped(_ sender: Any) {
    guard let phoneNumber = phoneNumber, let countryCode = countryCode else { return }
    
    authAPITask?.cancel()
    
    authAPITask = PhoneService.startVerification(forPhoneNumber: phoneNumber, countryCode: countryCode, completion: { [weak self] (error) in
      
      DispatchQueue.main.async {
        self?.dismissLoading()
        
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        self?.performSegue(withIdentifier: R.segue.signInMobileViewController.showVerifyCode, sender: nil)
      }
    })
  }
  
  // MARK: - private
  private func validate() {
    phoneNumberTextField.text?.isMobileNumber({ (isMobile, coutryCode, phoneNumber) in
      nextButton.isEnabled = isMobile
      self.countryCode = coutryCode
      self.phoneNumber = phoneNumber
    })
  }
  
}
