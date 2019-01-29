//
//  VerifyCodeViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 31/10/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class VerifyCodeViewController: UIViewController {
  
  enum VerifyCodeViewControllerNextStep {
    case signUp
    case updatePhone
  }
  
  @IBOutlet weak var infoLabel: UILabel!
  @IBOutlet weak var codeTextField: UITextField!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var resendButton: UIButton!
  
  var nextStep: VerifyCodeViewControllerNextStep = .signUp
  var countryCode: UInt64?
  var phoneNumber: String?
  var apiTask: URLSessionDataTask?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    infoLabel.text = R.string.localizable.kEnterVerificationCode()
    codeTextField.becomeFirstResponder()
  }
  
  @IBAction func codeChanged(_ sender: Any) {
    nextButton.isEnabled = codeTextField.text?.isFourDigits() ?? false
  }
  
  
  @IBAction func nextButtonTapped(_ sender: Any) {
    guard let phoneNumber = phoneNumber else { return }
    guard let countryCode = countryCode else { return }
    guard let verificationCode = codeTextField.text, verificationCode.isFourDigits() else { return }
    
    // update UI before calling API
    infoLabel.text = R.string.localizable.kVerifying()
    codeTextField.resignFirstResponder()
    codeTextField.isEnabled = false
    nextButton.isEnabled = false
    resendButton.isEnabled = false
    
    // cancel previous API call
    apiTask?.cancel()
    
    // create a new API call
    switch nextStep {
    case .signUp:
      apiTask = AuthService
        .signup(withPhoneNumber: phoneNumber, countryCode: countryCode, verificationCode: verificationCode, completion: { [weak self] (error) in
          
          self?.handleVerificationCompletion(error)
        })
    case .updatePhone:
      apiTask = UserService.udpatePhoneNumber(phoneNumber, countryCode: countryCode, verificationCode: verificationCode, completion: { [weak self] (error) in
        
        self?.handleVerificationCompletion(error)
      })
    }
    
  }
  
  @IBAction func resendButtonTapped(_ sender: Any) {
    guard let phoneNumber = phoneNumber else { return }
    guard let countryCode = countryCode else { return }
    
    // update UI before calling API
    infoLabel.text = R.string.localizable.kSendingVerificationCode()
    codeTextField.text = ""
    codeTextField.resignFirstResponder()
    codeTextField.isEnabled = false
    nextButton.isEnabled = false
    resendButton.isEnabled = false
    
    // cancel previous API call
    apiTask?.cancel()
    
    // create a new API call
    apiTask = PhoneService.startVerification(forPhoneNumber: phoneNumber, countryCode: countryCode, completion: { [weak self] (error) in
      
      DispatchQueue.main.async {
        if let error = error {
          self?.alertError(error)
        }
        
        // reset UI
        self?.infoLabel.text = R.string.localizable.kEnterVerificationCode()
        self?.codeTextField.isEnabled = true
        self?.codeTextField.becomeFirstResponder()
        self?.nextButton.isEnabled = true
        self?.resendButton.isEnabled = true
      }
    })
  }
  
  private func handleVerificationCompletion(_ error: Error?) {
    DispatchQueue.main.async {
      if let error = error {
        self.alertError(error)
      } else {
        switch self.nextStep {
        case .signUp:
          if Defaults[.userOnboarded] {
            self.performSegue(withIdentifier: R.segue.verifyCodeViewController.fromVerifyCodeToMain.identifier, sender: nil)
          }
          else {
            self.performSegue(withIdentifier: R.segue.verifyCodeViewController.fromVerifyCodeToOnboard.identifier, sender: nil)
          }
        case .updatePhone:
          self.performSegue(withIdentifier: R.segue.verifyCodeViewController.fromVerifyCodeToSettings.identifier, sender: nil)
        }
      }
      
      // reset UI
      self.infoLabel.text = R.string.localizable.kEnterVerificationCode()
      self.codeTextField.isEnabled = true
      self.nextButton.isEnabled = true
      self.resendButton.isEnabled = true
    }
  }
}
