//
//  VerifyCodeViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 31/10/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class VerifyCodeViewController: UIViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var resendButton: UIButton!
    
    var countryCode: UInt64?
    var phoneNumber: String?
    var userServiceTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        infoLabel.text = L10n.kEnterVerificationCode
        codeTextField.becomeFirstResponder()
    }
    
    @IBAction func codeChanged(_ sender: Any) {
        // TODO: format 4-digit code
        // https://github.com/mnvoh/DigitInputView
        
        nextButton.isEnabled = codeTextField.text?.isFourDigits() ?? false
    }
    
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        guard let phoneNumber = phoneNumber else { return }
        guard let countryCode = countryCode else { return }
        guard let verificationCode = codeTextField.text, verificationCode.isFourDigits() else { return }
        
        // update UI before calling API
        infoLabel.text = L10n.kVerifying
        codeTextField.resignFirstResponder()
        codeTextField.isEnabled = false
        nextButton.isEnabled = false
        resendButton.isEnabled = false
        
        // cancel previous API call
        userServiceTask?.cancel()
        
        // create a new API call
        userServiceTask = UserService()
            .signup(withPhoneNumber: phoneNumber, countryCode: countryCode, verificationCode: verificationCode, completion: { [weak self] (error) in
                
                DispatchQueue.main.async {
                    if let error = error {
                        self?.showError(error)
                    } else {
                        if Defaults[.userOnboarded] {
                            self?.perform(segue: StoryboardSegue.SignIn.fromVerifyCodeToMain)
                        }
                        else {
                            self?.perform(segue: StoryboardSegue.SignIn.fromVerifyCodeToOnboard)
                        }
                    }
                    
                    // reset UI
                    self?.infoLabel.text = L10n.kEnterVerificationCode
                    self?.codeTextField.isEnabled = true
                    self?.nextButton.isEnabled = true
                    self?.resendButton.isEnabled = true
                }
            })
    }
    
    @IBAction func resendButtonTapped(_ sender: Any) {
        guard let phoneNumber = phoneNumber else { return }
        guard let countryCode = countryCode else { return }
        
        // update UI before calling API
        infoLabel.text = L10n.kSendingVerificationCode
        codeTextField.text = ""
        codeTextField.resignFirstResponder()
        codeTextField.isEnabled = false
        nextButton.isEnabled = false
        resendButton.isEnabled = false
        
        // cancel previous API call
        userServiceTask?.cancel()
        
        // create a new API call
        userServiceTask = UserService().startVerification(forPhoneNumber: phoneNumber, countryCode: countryCode, completion: { [weak self] (error) in
            
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error)
                }
                
                // reset UI
                self?.infoLabel.text = L10n.kEnterVerificationCode
                self?.codeTextField.isEnabled = true
                self?.nextButton.isEnabled = true
                self?.resendButton.isEnabled = true
            }
        })
    }
    
    
}
