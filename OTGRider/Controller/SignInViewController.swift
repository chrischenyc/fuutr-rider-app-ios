//
//  SignInViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 31/10/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var mobileNextButton: UIButton!
    @IBOutlet weak var mobileVerifyInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mobileNextButton.isEnabled = false
    }
    
    
    @IBAction func mobileChanged(_ sender: Any) {
        if let mobile = mobileTextField.text {
            // TODO: format mobile number as 04xx xxx xxx
        }
        
        mobileNextButton.isEnabled = mobileTextField.text?.isAustralianMobile() ?? false
    }
    
    @IBAction func mobileNextTapped(_ sender: Any) {
        mobileNextButton.isEnabled = false
        mobileVerifyInfoLabel.text = NSLocalizedString("kSendingVerificationCode", comment: "")
        
        // TODO: call API to get verificaiton code
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.perform(segue: StoryboardSegue.SignIn.showMobileVerificationCode, sender: nil)
        })
    }
    
    @IBAction func unwindToSignIn(_ unwindSegue: UIStoryboardSegue) {
        
    }
}
