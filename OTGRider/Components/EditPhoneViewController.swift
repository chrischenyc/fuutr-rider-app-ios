//
//  EditPhoneViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 9/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit

class EditPhoneViewController: UIViewController {
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var phoneNumberVerifyButton: UIButton!
    @IBOutlet weak var phoneNumberVerifyInfoLabel: UILabel!
    
    var countryCode: UInt64?
    var phoneNumber: String?
    private var newCountryCode: UInt64?
    private var newPhoneNumber: String?
    private var apiTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberVerifyInfoLabel.text = L10n.kPhoneNumberVerificationPrompt
        phoneNumberVerifyButton.isEnabled = false
    }
    
    @IBAction func phoneNumberChanged(_ sender: Any) {
        phoneNumberTextField.text?.isMobileNumber({ (isMobile, coutryCode, phoneNumber) in
            
            self.newCountryCode = coutryCode
            self.newPhoneNumber = phoneNumber
            
            phoneNumberVerifyButton.isEnabled = isMobile &&
                (self.newCountryCode != self.countryCode && self.newPhoneNumber != self.phoneNumber)
        })
    }
    
    @IBAction func phoneNumberVerifyTapped(_ sender: Any) {
        guard let newPhoneNumber = newPhoneNumber, let newCountryCode = newCountryCode else { return }
        
        // update UI before calling API
        phoneNumberVerifyInfoLabel.text = L10n.kSendingVerificationCode
        phoneNumberTextField.resignFirstResponder()
        phoneNumberTextField.isEnabled = false
        phoneNumberVerifyButton.isEnabled = false
        
        // cancel previous API call
        apiTask?.cancel()
        
        // create a new API call
        apiTask = PhoneService.startVerification(forPhoneNumber: newPhoneNumber, countryCode: newCountryCode, completion: { [weak self] (error) in
            DispatchQueue.main.async {
                // reset UI
                self?.phoneNumberVerifyInfoLabel.text = L10n.kPhoneNumberVerificationPrompt
                self?.phoneNumberVerifyButton.isEnabled = true
                self?.phoneNumberTextField.isEnabled = true
                self?.phoneNumberVerifyButton.isEnabled = true
                
                if let error = error {
                    self?.alertError(error)
                } else {
                    self?.perform(segue: StoryboardSegue.Settings.fromEditPhoneToVerify)
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let verifyCodeViewController = segue.destination as? VerifyCodeViewController {
            guard let newPhoneNumber = newPhoneNumber, let newCountryCode = newCountryCode else { return }
            
            verifyCodeViewController.nextStep = .updatePhone
            verifyCodeViewController.countryCode = newCountryCode
            verifyCodeViewController.phoneNumber = newPhoneNumber
        }
    }
    
}
