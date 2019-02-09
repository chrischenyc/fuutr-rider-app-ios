//
//  ManualUnlockViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 15/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation

import IHKeyboardAvoiding
import PinCodeView

class ManualUnlockViewController: UnlockViewController {
  
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var pincodeView: PinCodeView! {
    didSet {
      pincodeView.delegate = self
      pincodeView.numberOfDigits = 6
      pincodeView.groupingSize = 0
      pincodeView.itemSpacing = 10
      pincodeView.digitViewInit = PinCodeDigitSquareView.init
    }
  }
  
  override func viewDidLoad() {
    navigationController?.navigationBar.applyLightTheme()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    KeyboardAvoiding.avoidingView = stackView
    pincodeView.becomeFirstResponder()
  }
}

extension ManualUnlockViewController: PinCodeViewDelegate {
  func pinCodeView(_ view: PinCodeView, didInsertText text: String) {
    
  }
  
  func pinCodeView(_ view: PinCodeView, didSubmitPinCode code: String, isValidCallback callback: @escaping (Bool) -> Void) {
    
    pincodeView.resignFirstResponder()
    
    unlockVehicle(unlockCode: code, onGeneralError: { [weak self] error in
      
      callback(false)
      
      self?.alertError(error, actionButtonTapped: {
        view.resetDigits()
        self?.pincodeView.becomeFirstResponder()
      })
    })
  }
}
