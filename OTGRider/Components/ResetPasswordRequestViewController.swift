//
//  ResetPasswordRequestViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 12/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit

class ResetPasswordRequestViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    private var apiTask: URLSessionTask?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.isEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let verifyCodeViewController = segue.destination as? ResetPasswordVerifyViewController {
            verifyCodeViewController.email = emailTextField.text
        }
    }
    
    @IBAction func emailChanged(_ sender: Any) {
        guard let email = emailTextField.text else {
            submitButton.isEnabled = false
            return
        }
        
        submitButton.isEnabled = email.isEmail()
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        
        apiTask?.cancel()
        
        showLoading()
        apiTask = AuthService().requestPasswordResetCode(forEmail: email, completion: { [weak self] (error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    self?.dismissLoading(withMessage: error?.localizedDescription)
                    return
                }
                
                self?.perform(segue: StoryboardSegue.SignIn.fromResetPasswordSendCodeToVerifyCode)
            }
        })
    }
    
}
