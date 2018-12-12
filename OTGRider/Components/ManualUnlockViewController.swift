//
//  ManualUnlockViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 15/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation


class ManualUnlockViewController: UnlockViewController {
    @IBOutlet weak var codeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeTextField.becomeFirstResponder()
    }
    
    @IBAction func codeChanged(_ sender: Any) {
        guard let code = codeTextField.text, code.isFourDigits() else { return }
        
        unlockVehicle(vehicleCode: code)
    }
}
