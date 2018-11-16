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
    private var clusterManager: GMUClusterManager!
    private let countryZoomLevel: Float = 3.6
    private let streetZoomLevel: Float = 16.0
    private let defaultCoordinate = CLLocationCoordinate2D(latitude: -26.0, longitude: 133.5)   // centre of Australia
    private let searchReferTime: TimeInterval = 1.5
    private var searchAPITask: URLSessionTask?
    private var scheduledSearchTimer: Timer?
    private let scooterInfoViewBottomToSuperView: CGFloat = 194
    private let rideInfoViewBottomToSuperView: CGFloat = 206
    var ride: Ride?
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var guideButton: UIButton!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var scooterInfoView: ScooterInfoView!
    @IBOutlet weak var scooterInfoViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rideInfoView: RideInfoView!
    @IBOutlet weak var rideInfoViewBottomConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenuButton.backgroundColor = UIColor.clear
        guideButton.layoutCornerRadiusAndShadow()
        guideButton.backgroundColor = UIColor.otgWhite
        scanButton.layoutCornerRadiusAndShadow()
        scanButton.backgroundColor = UIColor.otgWhite
        scooterInfoView.backgroundColor = UIColor.otgWhite
        scooterInfoView.layoutCornerRadiusAndShadow()
        scooterInfoViewBottomConstraint.constant = 0
        rideInfoView.backgroundColor = UIColor.otgWhite
        rideInfoView.layoutCornerRadiusAndShadow()
        rideInfoViewBottomConstraint.constant = 0
        
        // init Google Map with default view
        let camera = GMSCameraPosition.camera(withLatitude: defaultCoordinate.latitude,
                                              longitude: defaultCoordinate.longitude,
                                              zoom: countryZoomLevel)
        mapView.camera = camera
        mapView.delegate = self
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "GoogleMapStyle", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                logger.error("Unable to find style.json")
            }
        } catch {
            logger.error("One or more of the map styles failed to load. \(error)")
        }
        
        
        // Set up the cluster manager with the supplied icon generator and renderer.
        // https://developers.google.com/maps/documentation/ios-sdk/utility/marker-clustering
        
        let iconGenerator = GMUDefaultClusterIconGenerator(buckets: [10, 20, 50, 100],
                                                           backgroundImages: [Asset.sideMenuIcon.image,
                                                                              Asset.sideMenuIcon.image,
                                                                              Asset.sideMenuIcon.image,
                                                                              Asset.sideMenuIcon.image])
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        clusterManager.setDelegate(self, mapDelegate: self)
        
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        hideScooterInfo()
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
        else if let _ = sourceViewController as? UnlockViewController,
            let ride = ride,
            let unwindSegueWithCompletion = unwindSegue as? UIStoryboardSegueWithCompletion {
            logger.debug("show ride \(ride)")
            
            unwindSegueWithCompletion.completion = {
                self.showRideInfo(ride: ride)
            }
        }
    }
    
    private func promptForLocationService() {
        alertMessage("This app needs access to the location service so it can find scooters close to you and track your rides.", actionButtonTitle: "Grant access") {
            
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
    
    @objc private func searchScooters() {
        searchAPITask?.cancel()
        
        let currentMapViewBounds = GMSCoordinateBounds(region: mapView.projection.visibleRegion())
        let northEast = currentMapViewBounds.northEast
        let southWest = currentMapViewBounds.southWest
        
        searchAPITask = ScooterService().searchInBound(minLatitude: southWest.latitude,
                                                       minLongitude: southWest.longitude,
                                                       maxLatitude: northEast.latitude,
                                                       maxLongitude: northEast.longitude,
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
        DispatchQueue.main.async {
            // add new item
            let items = scooters.map { (scooter) -> ScooterPOIItem in
                let item = ScooterPOIItem(scooter: scooter)
                
                return item
            }
            self.clusterManager.add(items)
            
            self.clusterManager.cluster()
        }
    }
    
    private func showScooterInfo(scooter: ScooterPOIItem) {
        self.scooterInfoView.updateContentWith(scooter: scooter)
        self.scooterInfoViewBottomConstraint.constant = self.scooterInfoViewBottomToSuperView
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideScooterInfo() {
        self.scooterInfoViewBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func showRideInfo(ride: Ride) {
        self.rideInfoView.updateContent(withRide: ride)
        self.rideInfoViewBottomConstraint.constant = self.rideInfoViewBottomToSuperView
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideRideInfo() {
        self.rideInfoViewBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
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
        
        locationManager.stopUpdatingLocation()
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: streetZoomLevel)
        mapView.animate(to: camera)
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        
        logger.error(error.localizedDescription)
    }
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        scheduledSearchTimer?.invalidate()
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        scheduledSearchTimer?.invalidate()
        
        scheduledSearchTimer = Timer.scheduledTimer(timeInterval: searchReferTime,
                                                    target: self,
                                                    selector: #selector(searchScooters),
                                                    userInfo: nil,
                                                    repeats: false)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let scooter = marker.userData as? ScooterPOIItem {
            logger.debug("Did tap a normal marker for scooter item \(String(describing: scooter.vehicleCode))")
            showScooterInfo(scooter: scooter)
        }
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        hideScooterInfo()
    }
}

// MARK: - GMUClusterManagerDelegate
extension MapViewController: GMUClusterManagerDelegate {
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position, zoom: mapView.camera.zoom + 1)
        mapView.animate(to: newCamera)
        
        return true
    }
}

// MARK: - GMUClusterRendererDelegate
extension MapViewController: GMUClusterRendererDelegate {
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        guard let scooter = marker.userData as? ScooterPOIItem else { return }
        
        let powerPercent = scooter.powerPercent ?? 0
        
        if 80...100 ~= powerPercent {
            marker.icon = Asset.scooterGreen.image
        } else if 60..<80 ~= powerPercent {
            marker.icon = Asset.scooterYellow.image
        } else if 30..<60 ~= powerPercent {
            marker.icon = Asset.scooterOrange.image
        } else {
            marker.icon = Asset.scooterRed.image
        }
        
    }
}
