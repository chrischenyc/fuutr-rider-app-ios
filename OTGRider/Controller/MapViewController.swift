//
//  MapViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 15/10/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    private let countryZoomLevel: Float = 3.6
    private let streetZoomLevel: Float = 15.0
    private let defaultCoordinate = CLLocationCoordinate2D(latitude: -26.0, longitude: 133.5)   // centre of Australia
    
    @IBOutlet weak var mapView: GMSMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init Google Map with default view
        let camera = GMSCameraPosition.camera(withLatitude: defaultCoordinate.latitude,
                                              longitude: defaultCoordinate.longitude,
                                              zoom: countryZoomLevel)
        mapView.camera = camera
        mapView.delegate = self
        
        // get user location
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        
        if let sideMenuViewController = sourceViewController as? SideMenuViewController,
            let selectedMenuItem = sideMenuViewController.selectedMenuItem {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                switch selectedMenuItem {
                case .wallet:
                    self.perform(segue: StoryboardSegue.Main.showWallet)
                case .history:
                    self.perform(segue: StoryboardSegue.Main.showHistory)
                case .juice:
                    self.perform(segue: StoryboardSegue.Main.showJuice)
                case .settings:
                    self.perform(segue: StoryboardSegue.Main.showSettings)
                case .help:
                    self.perform(segue: StoryboardSegue.Main.showHelp)
                }
                
            })
        }
    }
    
}

extension MapViewController: GMSMapViewDelegate {
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedAlways || status == .authorizedWhenInUse else {
            // TODO: handle the case when user declined to grant location access
            return
        }
        
        locationManager.startUpdatingLocation()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: streetZoomLevel)
        
        mapView.animate(to: camera)
        
        locationManager.stopUpdatingLocation()
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        
        print("Error: \(error)")
    }
}

