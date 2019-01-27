//
//  ManualUnlockViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 15/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation


class ManualUnlockViewController: UnlockViewController {
  
  @IBOutlet weak var enterCodeLabel: UILabel!
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var showQRCodeButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    enterCodeLabel.textColor = UIColor.primaryGreyColor
    showQRCodeButton.setTitleColor(UIColor.primaryRedColor, for: .normal)
    closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    showQRCodeButton.addTarget(self, action: #selector(showQRCode), for: .touchUpInside)
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
