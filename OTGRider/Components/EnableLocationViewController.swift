//
//  EnableLocationViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 31/10/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import CoreLocation

class EnableLocationViewController: UIViewController {
  
  private let locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // TODO: check if permission has been granted, segue to next screen
    
    // Do any additional setup after loading the view.
    locationManager.delegate = self
  }
  
  
  @IBAction func enableLocationTapped(_ sender: Any) {
    locationManager.requestAlwaysAuthorization()
  }
  
}

extension EnableLocationViewController: CLLocationManagerDelegate {
  
  // Handle authorization for the location manager.
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    guard status == .authorizedAlways || status == .authorizedWhenInUse else {
      // TODO: handle the case when user declined to grant location access
      return
    }
    
    if UIApplication.shared.isRegisteredForRemoteNotifications {
      // TODO: wrong segue is called
      performSegue(withIdentifier: R.segue.enableLocationViewController.showMap.identifier, sender: nil)
    } else {
      performSegue(withIdentifier: R.segue.enableLocationViewController.showEnableNotification.identifier, sender: nil)
    }
  }
  
}

