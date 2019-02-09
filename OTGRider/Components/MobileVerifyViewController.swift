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
import PinCodeView

class MobileVerifyViewController: UIViewController {
  
  enum VerifyCodeViewControllerNextStep {
    case signIn       // this screen is segued from email sign in
    case updatePhone  // this screen is segued fom change phone number
  }
  
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var pinCodeView: PinCodeView! {
    didSet {
      pinCodeView.delegate = self
      pinCodeView.numberOfDigits = 6
      pinCodeView.groupingSize = 0
      pinCodeView.itemSpacing = 12
      pinCodeView.digitViewInit = PinCodeDigitSquareView.init
    }
  }
  @IBOutlet weak var resendButton: UIButton!
  
  
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
    pinCodeView.becomeFirstResponder()
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
  
  @IBAction func resendButtonTapped(_ sender: Any) {
    guard let phoneNumber = phoneNumber else { return }
    guard let countryCode = countryCode else { return }
    
    apiTask?.cancel()
    
    pinCodeView.resetDigits()
    showLoading()
    
    apiTask = PhoneService.startVerification(forPhoneNumber: phoneNumber, countryCode: countryCode, completion: { [weak self] (error) in
      
      DispatchQueue.main.async {
        self?.dismissLoading()
        
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        self?.alertMessage(message: "We sent you a new verification coee")
      }
    })
  }
}

extension MobileVerifyViewController: PinCodeViewDelegate {
  func pinCodeView(_ view: PinCodeView, didSubmitPinCode code: String, isValidCallback callback: @escaping (Bool) -> Void) {
    
    guard let phoneNumber = phoneNumber else { return }
    guard let countryCode = countryCode else { return }
    
    apiTask?.cancel()
    
    showLoading()
    
    switch nextStep {
    case .signIn:
      apiTask = AuthService
        .signIn(withPhoneNumber: phoneNumber, countryCode: countryCode, verificationCode: code, completion: { [weak self] (error) in
          
          DispatchQueue.main.async {
            self?.dismissLoading()
            
            guard error == nil else {
              self?.pinCodeView.resetDigits()
              self?.alertError(error!)
              return
            }
            
            if Defaults[.userOnboarded] {
              self?.performSegue(withIdentifier: R.segue.mobileVerifyViewController.showMap, sender: nil)
            }
            else {
              self?.performSegue(withIdentifier: R.segue.mobileVerifyViewController.showPermissions, sender: nil)
            }
          }
        })
      
    case .updatePhone:
      apiTask = UserService.udpatePhoneNumber(phoneNumber, countryCode: countryCode, verificationCode: code, completion: { [weak self] (error) in
        
        DispatchQueue.main.async {
          self?.dismissLoading()
          
          guard error == nil else {
            self?.pinCodeView.resetDigits()
            self?.alertError(error!)
            return
          }
          
          self?.performSegue(withIdentifier: R.segue.mobileVerifyViewController.unwindToSettings, sender: nil)
        }
      })
    }
  }
  
  func pinCodeView(_ view: PinCodeView, didInsertText text: String) {
    // do nothing
  }
  
  
}
