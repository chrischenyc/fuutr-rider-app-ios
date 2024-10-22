//
//  EnableNotificationViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 31/10/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseInstanceID
import SwiftyUserDefaults

class PushNotificationPermissionViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  
  
  @IBAction func enableNotificationTapped(_ sender: Any) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
      
      if granted {
        InstanceID.instanceID().instanceID { (result, error) in
          if let error = error {
            print("Error fetching remote instange ID: \(error)")
          } else if let result = result {
            print("Remote instance ID token: \(result.token)")
            
            // TODO: send token to server
          }
        }
      }
      
      DispatchQueue.main.async {
        Defaults[.didRequestPushNotificationPermission] = true
        self.performSegue(withIdentifier: R.segue.pushNotificationPermissionViewController.showMain, sender: nil)
      }
    }
  }
  
  @IBAction func laterTapped(_ sender: Any) {
    Defaults[.didRequestPushNotificationPermission] = true
    self.performSegue(withIdentifier: R.segue.pushNotificationPermissionViewController.showMain, sender: nil)
  }
}
