//
//  UpdateEmailVerifyViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 15/02/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding
import PinCodeView

class UpdateEmailVerifyViewController: UIViewController {
  
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
  
  private var apiTask: URLSessionTask?
  var email: String?
  
  // lifecycle
  override func viewDidAppear(_ animated: Bool) {
    KeyboardAvoiding.avoidingView = stackView
    pinCodeView.becomeFirstResponder()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let setPasswordViewController = segue.destination as? ResetPasswordSetViewController,
      let code = sender as? String {
      setPasswordViewController.email = email
      setPasswordViewController.code = code
    }
  }
  
  // MARK: - user actions
  
  @IBAction func resendButtonTapped(_ sender: Any) {
    guard let email = email else { return }
    
    apiTask?.cancel()
    
    showLoading()
    
    pinCodeView.resetDigits()
    showLoading()
    
    apiTask = AuthService.requestUpdateEmailCode(to: email, completion: { [weak self] (error) in
      
      DispatchQueue.main.async {
        
        self?.dismissLoading()
        
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        self?.alertMessage(title: "Check your email!",
                           message: "We sent a new verification code to \(email)",
                           image: R.image.successCheck())
      }
    })
  }
}

extension UpdateEmailVerifyViewController: PinCodeViewDelegate {
  func pinCodeView(_ view: PinCodeView, didSubmitPinCode code: String, isValidCallback callback: @escaping (Bool) -> Void) {
    
    guard let email = email else { return }
    
    apiTask?.cancel()
    
    showLoading()
    
    apiTask = AuthService.updateEmail(to: email, code: code, completion: { [weak self] (error) in
      DispatchQueue.main.async {
        self?.dismissLoading()
        
        guard error == nil else {
          self?.pinCodeView.resetDigits()
          self?.alertError(error!)
          return
        }
        
        self?.alertMessage(title: "Email has been updated to \(email)",
          message: nil,
          image: nil,
          positiveActionButtonTapped: {
            self?.performSegue(withIdentifier: R.segue.updateEmailVerifyViewController.unwindToSettings, sender: nil)
        })
        
      }
    })
  }
  
  func pinCodeView(_ view: PinCodeView, didInsertText text: String) {
    // do nothing
  }
  
  
}
