//
//  ManualUnlockViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 15/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation

import PinCodeView

class ManualUnlockViewController: UnlockViewController {
  
  @IBOutlet weak var enterCodeLabel: UILabel!
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var showQRCodeButton: UIButton!
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
    super.viewDidLoad()
    enterCodeLabel.textColor = UIColor.primaryGreyColor
    showQRCodeButton.setTitleColor(UIColor.primaryRedColor, for: .normal)
    closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    showQRCodeButton.addTarget(self, action: #selector(showQRCode), for: .touchUpInside)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    pincodeView.becomeFirstResponder()
  }
  
  @objc private func close() {
    self.dismiss(animated: true, completion: nil)
  }
  
  @objc private func showQRCode() {
    self.performSegue(withIdentifier: "unwindToScanUnlock", sender: self)
  }
  
  @objc private func codeChanged(_ sender: Any) {
//    guard let code = codeTextField.text, code.isSixDigits() else { return }
//    unlockVehicle(unlockCode: code)
  }
}

extension ManualUnlockViewController: PinCodeViewDelegate {
  func pinCodeView(_ view: PinCodeView, didInsertText text: String) {
    
  }
  
  func pinCodeView(_ view: PinCodeView, didSubmitPinCode code: String, isValidCallback callback: @escaping (Bool) -> Void) {
    
    view.alpha = 0.5
    
    // check server for code validity, etc
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      view.alpha = 1
      
      callback(false)
    }
  }
}
