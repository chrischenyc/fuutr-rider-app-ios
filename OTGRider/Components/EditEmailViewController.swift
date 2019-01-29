//
//  EditEmailViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 9/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit

class EditEmailViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var email: String?
    var apiTask: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.text = email
        emailTextField.becomeFirstResponder()
        submitButton.isEnabled = false
    }
    
    @IBAction func nameChanged(_ sender: Any) {
        guard let newEmail = emailTextField.text else {
            submitButton.isEnabled = false
            return
        }
        
        submitButton.isEnabled = (email != newEmail && newEmail.isEmail())
    }
    
    @IBAction func updateTouched(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        
        apiTask?.cancel()
        
        showLoading()
        
        apiTask = UserService.updateEmail(email, completion: { [weak self] (error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    self?.flashErrorMessage(error?.localizedDescription)
                    return
                }
                
                self?.perform(segue: StoryboardSegue.Settings.fromEditEmailToSettings)
            }
        })
    }
    
}
