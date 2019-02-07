//
//  SignInPasswordViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 7/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit

class SignInPasswordViewController: UIViewController {
  
  var email: String?
  var displayName: String?  // if it has value, it's a sign in case; otherwise, sign up
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    if let displayName = displayName {
      title = "G'day, \(displayName)!"
    }
    else {
      title = "G'day!"
    }
  }
  
}
