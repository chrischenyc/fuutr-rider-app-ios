//
//  EmailAuthViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 6/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class EmailAuthViewController: UIViewController {
    
    private enum EmailAuthType {
        case signUp
        case logIn
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    private var authType: EmailAuthType = .signUp
    private var apiTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.isEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.SignIn.fromSignUpToLogIn.rawValue {
            if let emailAuthViewController = segue.destination as? EmailAuthViewController {
                emailAuthViewController.authType = .logIn
            }
        }
    }
    
    @IBAction func unwindToEmailSignUp(_ unwindSegue: UIStoryboardSegue) {
        authType = .signUp
    }
    
    @IBAction func emailChanged(_ sender: Any) {
        validateInput()
    }
    
    @IBAction func passwordChanged(_ sender: Any) {
        validateInput()
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        guard let passowrd = passwordTextField.text else { return }
        
        // cancel previous API call
        apiTask?.cancel()
        
        // create a new API call
        showLoading()
        
        if authType == .signUp {
            apiTask = AuthService().signup(withEmail: email, password: passowrd, completion: { [weak self] (error) in
                self?.handleAuthCompletion(error: error)
            })
        } else {
            apiTask = AuthService().login(withEmail: email, password: passowrd, completion: {[weak self] (error) in
                self?.handleAuthCompletion(error: error)
            })
        }
    }
    
    private func validateInput() {
        guard let validEmail = emailTextField.text?.isEmail(), validEmail == true else {
            submitButton.isEnabled = false
            return
        }
        
        guard let validPassword = passwordTextField.text?.isValidPassword(), validPassword == true else {
            submitButton.isEnabled = false
            return
        }
        
        submitButton.isEnabled = true
    }
    
    private func handleAuthCompletion(error: Error?) {
        DispatchQueue.main.async {
            // reset UI
            if let error = error {
                self.dismissLoading(withMessage: error.localizedDescription)
            } else {
                self.dismissLoading()
                if Defaults[.userOnboarded] {
                    self.perform(segue: self.authType == .signUp ?
                        StoryboardSegue.SignIn.fromEmailSignUpToMain :
                        StoryboardSegue.SignIn.fromEmailLogInToMain)
                }
                else {
                    self.perform(segue: self.authType == .signUp ?
                        StoryboardSegue.SignIn.fromEmailSignUpToOnboard :
                        StoryboardSegue.SignIn.fromEmailLogInToOnboard)
                }
            }
        }
    }
}
