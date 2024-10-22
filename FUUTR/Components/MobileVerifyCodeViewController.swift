//
//  MobileRequestCodeViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 31/10/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import IHKeyboardAvoiding
import PinCodeView

class MobileVerifyCodeViewController: UIViewController {
  
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
  
  
  var action: MobileVerifyAction = .signIn
  var countryCode: UInt64?
  var phoneNumber: String?
  var apiTask: URLSessionDataTask?
  
  // MARK: - lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyLightTheme()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    KeyboardAvoiding.avoidingView = stackView
    pinCodeView.becomeFirstResponder()
  }
  
  
  // MARK: - user actions
  
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
        
        self?.alertMessage(message: "We sent you a new verification code",
                           image: R.image.imgSuccessCheck(),
                           hapticFeedbackType: .success)
      }
    })
  }
}

extension MobileVerifyCodeViewController: PinCodeViewDelegate {
  func pinCodeView(_ view: PinCodeView, didSubmitPinCode code: String, isValidCallback callback: @escaping (Bool) -> Void) {
    
    guard let phoneNumber = phoneNumber else { return }
    guard let countryCode = countryCode else { return }
    
    apiTask?.cancel()
    
    showLoading()
    
    switch action {
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
            
            self?.performSegue(withIdentifier: R.segue.mobileVerifyCodeViewController.showMain, sender: nil)
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
          
          self?.performSegue(withIdentifier: R.segue.mobileVerifyCodeViewController.unwindToSettings, sender: nil)
        }
      })
    }
  }
  
  func pinCodeView(_ view: PinCodeView, didInsertText text: String) {
    // do nothing
  }
  
  
}
