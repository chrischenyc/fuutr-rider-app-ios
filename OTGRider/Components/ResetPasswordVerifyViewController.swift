//
//  ResetPasswordVerifyViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 12/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding
import PinCodeView

class ResetPasswordVerifyViewController: UIViewController {
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyLightTheme()
  }
  
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
  
  @IBAction func unwindToResetPasswordVerify(_ unwindSegue: UIStoryboardSegue) {
    
  }
  
  // MARK: - user actions

  @IBAction func resendButtonTapped(_ sender: Any) {
    guard let email = email else { return }
    
    apiTask?.cancel()
    
    showLoading()
    
    pinCodeView.resetDigits()
    showLoading()
    
    apiTask = AuthService.requestPasswordResetCode(forEmail: email, completion: { [weak self] (error) in
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

extension ResetPasswordVerifyViewController: PinCodeViewDelegate {
  func pinCodeView(_ view: PinCodeView, didSubmitPinCode code: String, isValidCallback callback: @escaping (Bool) -> Void) {
    
    guard let email = email else { return }
    
    apiTask?.cancel()
    
    showLoading()
    
    apiTask = AuthService.verifyPasswordResetCode(forEmail: email, code: code, completion: { [weak self] (error) in
      DispatchQueue.main.async {
        self?.dismissLoading()
        
        guard error == nil else {
          self?.pinCodeView.resetDigits()
          self?.alertError(error!)
          return
        }
        
        self?.performSegue(withIdentifier: R.segue.resetPasswordVerifyViewController.showSetPassword, sender: code)
      }
    })
  }
  
  func pinCodeView(_ view: PinCodeView, didInsertText text: String) {
    // do nothing
  }
  
  
}
