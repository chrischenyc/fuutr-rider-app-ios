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
    private var searchAPITask: URLSessionTask?
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init Google Map with default view
        let camera = GMSCameraPosition.camera(withLatitude: defaultCoordinate.latitude,
                                              longitude: defaultCoordinate.longitude,
                                              zoom: countryZoomLevel)
        mapView.camera = camera
        mapView.delegate = self
        
        // request location permisison if needed
        locationManager.delegate = self
        switch CLLocationManager.authorizationStatus() {
        case .denied,
             .restricted:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.promptForLocationService()
            }
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        default:
            break   // delegate method didChangeAuthorization will be called if permission has been authorized
        }
    }
    
    
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        
        if let sideMenuViewController = sourceViewController as? SideMenuViewController,
            let selectedMenuItem = sideMenuViewController.selectedMenuItem,
            let unwindSegueWithCompletion = unwindSegue as? UIStoryboardSegueWithCompletion {
            
            unwindSegueWithCompletion.completion = {
                switch selectedMenuItem {
                case .greeting:
                    break
                case .accont:
                    self.perform(segue: StoryboardSegue.Main.showAccount)
                case .history:
                    self.perform(segue: StoryboardSegue.Main.showHistory)
                case .settings:
                    self.perform(segue: StoryboardSegue.Main.showSettings)
                case .help:
                    if let url = URL(string: config.env.helpURL), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    
                    // in case we need to integrate and present help desk page in app
                    // self.perform(segue: StoryboardSegue.Main.showHelp)
                }
                
            }
        }
    }
    
    private func promptForLocationService() {
        showMessage("This app needs access to the location service so it can find scooters close to you and track your rides.", actionButtonTitle: "Grant access") {
            
            if !CLLocationManager.locationServicesEnabled() {
                if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {
                    // If general location settings are disabled then open general location settings
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    // If general location settings are enabled then open location settings for the app
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    
    private func searchScooters() {
        let cameraPosition: GMSCameraPosition = mapView.camera
        let coordinate = cameraPosition.target
        let zoom = cameraPosition.zoom
        
        searchAPITask?.cancel()
        searchAPITask = ScooterService().search(latitude: coordinate.latitude,
                                          longitude: coordinate.longitude,
                                          radius: 5,
                                          completion: { [weak self] (scooters, error) in
                                            guard error == nil else {
                                                logger.error(error?.localizedDescription)
                                                return
                                            }
                                            
                                            guard let scooters = scooters else {
                                                return
                                            }
                                            
                                            self?.addMapMakers(forScooters: scooters)
        })
    }
    
    private func addMapMakers(forScooters scooters: [Scooter]) {
        logger.debug(scooters)
        // TODO: add to google map
    }
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        searchAPITask?.cancel()
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        searchAPITask?.cancel()
        
        logger.debug("moved to: \(position.target.latitude) \(position.target.longitude)")
        logger.debug("map camera: \(mapView.camera.target.latitude) \(mapView.camera.target.longitude)")
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return true
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedAlways || status == .authorizedWhenInUse else {
            promptForLocationService()
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
        
        searchScooters()
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        
        logger.error(error.localizedDescription)
    }
}

