//
//  MobileVerifyViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 31/10/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import IHKeyboardAvoiding

class MobileVerifyViewController: UIViewController {
  
  enum VerifyCodeViewControllerNextStep {
    case signIn
    case updatePhone
  }
  
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var codeTextField: UITextField!
  @IBOutlet weak var resendButton: UIButton!
  
  // this screen is re-used by sign-in and change phone number
  var nextStep: VerifyCodeViewControllerNextStep = .signIn
  var countryCode: UInt64?
  var phoneNumber: String?
  var apiTask: URLSessionDataTask?
  
  // MARK: - lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyTheme()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    KeyboardAvoiding.avoidingView = stackView
    codeTextField.becomeFirstResponder()
  }
  
  
  // MARK: - user actions
  
  @IBAction func onBack(_ sender: Any) {
    switch nextStep {
    case .signIn:
      performSegue(withIdentifier: R.segue.mobileVerifyViewController.unwindToSignInMobile, sender: nil)
      
    case .updatePhone:
      performSegue(withIdentifier: R.segue.mobileVerifyViewController.unwindToSettings, sender: nil)
    }
  }
  
  @IBAction func codeChanged(_ sender: Any) {
    // TODO: trigger submit
  }
  
  
  private func submit() {
    guard let phoneNumber = phoneNumber else { return }
    guard let countryCode = countryCode else { return }
    guard let verificationCode = codeTextField.text, verificationCode.isFourDigits() else { return }
    
    apiTask?.cancel()
    
    showLoading()
    
    switch nextStep {
    case .signIn:
      apiTask = AuthService
        .signup(withPhoneNumber: phoneNumber, countryCode: countryCode, verificationCode: verificationCode, completion: { [weak self] (error) in
          
          DispatchQueue.main.async {
            self?.dismissLoading()
            self?.handleVerificationCompletion(error)
          }
        })
      
    case .updatePhone:
      apiTask = UserService.udpatePhoneNumber(phoneNumber, countryCode: countryCode, verificationCode: verificationCode, completion: { [weak self] (error) in
        
        DispatchQueue.main.async {
          self?.dismissLoading()
          self?.handleVerificationCompletion(error)
        }
      })
    }
    
  }
  
  @IBAction func resendButtonTapped(_ sender: Any) {
    guard let phoneNumber = phoneNumber else { return }
    guard let countryCode = countryCode else { return }
    
    // update UI before calling API
    codeTextField.text = ""
    
    apiTask?.cancel()
    
    showLoading()
    apiTask = PhoneService.startVerification(forPhoneNumber: phoneNumber, countryCode: countryCode, completion: { [weak self] (error) in
      
      DispatchQueue.main.async {
        self?.dismissLoading()
        
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        self?.alertMessage(title: "Done!", message: "We sent you a new verification code")
      }
    })
  }
  
  // MARK: - private
  
  private func handleVerificationCompletion(_ error: Error?) {
    guard error == nil else {
      self.alertError(error!)
      return
    }
    
    switch self.nextStep {
    case .signIn:
      if Defaults[.userOnboarded] {
        self.performSegue(withIdentifier: R.segue.mobileVerifyViewController.showMap, sender: nil)
      }
      else {
        self.performSegue(withIdentifier: R.segue.mobileVerifyViewController.showPermissions, sender: nil)
      }
      
    case .updatePhone:
      self.performSegue(withIdentifier: R.segue.mobileVerifyViewController.unwindToSettings, sender: nil)
    }
    
  }
}
