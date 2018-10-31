//
//  VerificationCodeViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 31/10/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class VerificationCodeViewController: UIViewController {
    
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func codeChanged(_ sender: Any) {
        // TODO: format 4-digit code
        // https://github.com/mnvoh/DigitInputView
        
        nextButton.isEnabled = codeTextField.text?.isFourDigits() ?? false
    }
    
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        nextButton.isEnabled = false
        
        // TODO: call API
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            Defaults[.userSignedIn] = true
            
            self.perform(segue: StoryboardSegue.SignIn.showOnboard, sender: nil)
        })
    }
    
    @IBAction func resendButtonTapped(_ sender: Any) {
        // TODO: call API
        nextButton.isEnabled = false
    }
    
    
}
