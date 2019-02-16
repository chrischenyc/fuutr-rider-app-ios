//
//  LocationPermissionViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 31/10/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyUserDefaults

class LocationPermissionViewController: UIViewController {
  
  private let locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    locationManager.delegate = self
  }
  
  
  @IBAction func enableLocationTapped(_ sender: Any) {
    locationManager.requestAlwaysAuthorization()
    Defaults[.didRequestLocationPermission] = true
  }
  
}

extension LocationPermissionViewController: CLLocationManagerDelegate {
  
  // Handle authorization for the location manager.
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    guard status == .authorizedAlways || status == .authorizedWhenInUse else {
      // TODO: handle the case when user declined to grant location access
      return
    }
    
    performSegue(withIdentifier: R.segue.locationPermissionViewController.showMain, sender: nil)
  }
  
}

