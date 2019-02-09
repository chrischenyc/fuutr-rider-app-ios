//
//  EditNameViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 9/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit

class EditNameViewController: UIViewController {
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var submitButton: UIButton!
  
  var displayName: String?
  var apiTask: URLSessionTask?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    nameTextField.text = displayName
    nameTextField.becomeFirstResponder()
    submitButton.isEnabled = false
  }
  
  @IBAction func nameChanged(_ sender: Any) {
    submitButton.isEnabled = (displayName != nameTextField.text)
  }
  
  @IBAction func updateTouched(_ sender: Any) {
    guard let displayName = nameTextField.text else { return }
    
    apiTask?.cancel()
    
    showLoading()
    
    apiTask = UserService.updateProfile(["displayName": displayName], completion: { [weak self] (error) in
      DispatchQueue.main.async {
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        self?.performSegue(withIdentifier: R.segue.editNameViewController.unwindToSettings, sender: nil)
      }
    })
  }
  
}
