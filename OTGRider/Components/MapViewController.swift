//
//  MapViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 15/10/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit
import GoogleMaps

var currentLocation: CLLocation?

class MapViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    private var clusterManager: GMUClusterManager!
    private let streetZoomLevel: Float = 16.0
    private let minDistanceFilter: CLLocationDistance = 3
    
    private var searchAPITask: URLSessionTask?
    private var rideAPITask: URLSessionTask?
    
    private var deferredSearchTimer: Timer?     // a new round of search API will be fired unless time gets invalidated
    private let searchDeferring: TimeInterval = 1.5
    private var rideLocalUpdateTimer: Timer?    // periodically update duration, distance, route
    private let localUpdateFrequency: TimeInterval = 1
    private var rideServerUpdateTimer: Timer?   // periodically report travelled coordinates to server
    private let serverUpdateFrequency: TimeInterval = 10
    private var serverUpdateThreshhold: CLLocationDistance = 10    // the minimum travel distance for a new server update
    private var didLoadOngoingRide: Bool = false
    
    var ongoingRide: Ride? {
        didSet {
            if let ongoingRide = ongoingRide {
                rideInfoView.updateContent(withRide: ongoingRide)
            }
            
            if ongoingRide != oldValue {
                updateUnlockButton()
            }
        }
    }
    
    private var ongoingRidePath: GMSMutablePath?    // to track travelled distance and to draw route
    private var ongoingRidePolyline: GMSPolyline?
    private var incrementalPath: GMSMutablePath?    // to report to server for the new segment
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var guideButton: UIButton!
    @IBOutlet weak var unlockButton: UIButton!
    @IBOutlet weak var vehicleInfoView: VehicleInfoView!
    @IBOutlet weak var vehicleInfoViewBottomConstraint: NSLayoutConstraint!
    private let vehicleInfoViewBottomToSuperView: CGFloat = 194
    @IBOutlet weak var rideInfoView: RideInfoView!
    @IBOutlet weak var rideInfoViewBottomConstraint: NSLayoutConstraint!
    private let rideInfoViewBottomToSuperView: CGFloat = 206
    @IBOutlet weak var pinImageView: UIImageView!
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupMapView()
        setupLocationManager()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // animate out vehicle banner before leaving
        hideVehicleInfo()
    }
    
    // MARK: - user actions
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
            let ride = ongoingRide,
            let unwindSegueWithCompletion = unwindSegue as? UIStoryboardSegueWithCompletion {
            // rewind from unlock, a new ride starts
            unwindSegueWithCompletion.completion = {
                self.startTrackingRide(ride)
            }
        }
    }
    
    @IBAction func unlockButtonTapped(_ sender: Any) {
        if ongoingRide != nil {
            lockVehicle()
        } else {
            perform(segue: StoryboardSegue.Main.fromMapToScan)
        }
    }
}

// MARK: - Ride Tracking
extension MapViewController {
    private func startTrackingRide(_ ride: Ride) {
        ongoingRide = ride
        
        showRideInfo()
        
        rideLocalUpdateTimer?.invalidate()
        rideLocalUpdateTimer = Timer.scheduledTimer(timeInterval: localUpdateFrequency,
                                                    target: self,
                                                    selector: #selector(self.updateRideLocally),
                                                    userInfo: nil,
                                                    repeats: true)
        
        rideServerUpdateTimer?.invalidate()
        rideServerUpdateTimer = Timer.scheduledTimer(timeInterval: serverUpdateFrequency,
                                                     target: self,
                                                     selector: #selector(self.updateRideToServer),
                                                     userInfo: nil,
                                                     repeats: true)
        
        pinImageView.image = nil
        
        // try to resume previously saved route
        if let encodedPath = ride.encodedPath, let decodedPath = GMSMutablePath(fromEncodedPath: encodedPath){
            ongoingRidePath = decodedPath
            
            drawRoute(forPath: decodedPath)
        }
        else {
            ongoingRidePath = GMSMutablePath()
        }
        
        incrementalPath = GMSMutablePath()
        if let currentLocation = currentLocation {
            ongoingRidePath?.add(currentLocation.coordinate)
            incrementalPath?.add(currentLocation.coordinate)
        }
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        // do not show vehicles during riding
        clearMapMakers()
    }
    
    private func stopTrackingRide() {
        ongoingRide = nil
        
        hideRideInfo()
        
        rideLocalUpdateTimer?.invalidate()
        rideServerUpdateTimer?.invalidate()
        
        pinImageView.image = Asset.pin.image
        
        ongoingRidePath = nil
        ongoingRidePolyline?.map = nil
        ongoingRidePolyline = nil
        incrementalPath = nil
        
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = true
        
        searchVehicles()
    }
    
    @objc private func updateRideLocally() {
        guard var ride = ongoingRide else { return }
        
        ride.refresh()
        ride.distance = ongoingRidePath?.length(of: GMSLengthKind.geodesic)
        
        self.ongoingRide = ride
    }
}

// MARK: - API
extension MapViewController {
    @objc private func searchVehicles() {
        // pause new vehicles search while user is during a ride
        guard ongoingRide == nil else { return }
        
        
        searchAPITask?.cancel()
        
        let currentMapViewBounds = GMSCoordinateBounds(region: mapView.projection.visibleRegion())
        let northEast = currentMapViewBounds.northEast
        let southWest = currentMapViewBounds.southWest
        
        searchAPITask = VehicleService.search(minLatitude: southWest.latitude,
                                              minLongitude: southWest.longitude,
                                              maxLatitude: northEast.latitude,
                                              maxLongitude: northEast.longitude,
                                              completion: { [weak self] (vehicles, error) in
                                                guard error == nil else {
                                                    logger.error(error?.localizedDescription)
                                                    return
                                                }
                                                
                                                guard let vehicles = vehicles else {
                                                    return
                                                }
                                                
                                                self?.addMapMakers(forVehicles: vehicles)
        })
    }
    
    private func loadOngoingRide() {
        guard ongoingRide == nil else { return }
        guard !didLoadOngoingRide else { return }
        
        didLoadOngoingRide = true   // only attempt to load ongoing ride the first time app launches
        
        rideAPITask?.cancel()
        
        rideAPITask = RideService.getOngoingRide({[weak self] (ride, error) in
            
            DispatchQueue.main.async {
                guard error == nil else {
                    logger.error(error!.localizedDescription)
                    return
                }
                
                guard let ride = ride else {
                    logger.debug("No open ride found")
                    return
                }
                
                // resume tracking an ongoing ride
                self?.startTrackingRide(ride)
            }
        })
    }
    
    private func lockVehicle() {
        guard let id = ongoingRide?.id else { return }
        guard let coordinate = currentLocation?.coordinate else { return }
        guard let incrementalPath = incrementalPath else { return }
        
        rideAPITask?.cancel()
        
        showLoading(withMessage: "Locking scooter")
        rideAPITask = RideService.finish(rideId: id,
                                         coordinate: coordinate,
                                         incrementalEncodedPath: incrementalPath.encodedPath(),
                                         incrementalDistance: incrementalPath.length(of: GMSLengthKind.geodesic),
                                         completion: { [weak self] (ride, error) in
                                            DispatchQueue.main.async {
                                                self?.dismissLoading()
                                                
                                                guard error == nil else {
                                                    self?.alertError(error!)
                                                    return
                                                }
                                                
                                                guard let ride = ride else {
                                                    self?.alertMessage(L10n.kOtherError)
                                                    return
                                                }
                                                
                                                self?.showCompletedRide(ride)
                                                
                                                self?.stopTrackingRide()
                                            }
        })
    }
    
    @objc private func updateRideToServer() {
        guard let rideId = ongoingRide?.id else { return }
        guard let path = incrementalPath, path.length(of: GMSLengthKind.geodesic) > serverUpdateThreshhold else { return }
        
        rideAPITask?.cancel()
        
        rideAPITask = RideService.update(rideId: rideId,
                                         incrementalEncodedPath: path.encodedPath(),
                                         incrementalDistance: path.length(of: GMSLengthKind.geodesic)) { (error) in
                                            logger.error(error)
                                            
                                            if error != nil {
                                                // TODO: merge path coordinates which was failed to upload
                                            }
        }
        
        // reset incremental path straight away
        incrementalPath = GMSMutablePath()
    }
}

// MARK: - UI
extension MapViewController {
    private func setupUI() {
        sideMenuButton.backgroundColor = UIColor.clear
        guideButton.layoutCornerRadiusAndShadow()
        guideButton.backgroundColor = UIColor.otgWhite
        unlockButton.layoutCornerRadiusAndShadow()
        unlockButton.backgroundColor = UIColor.otgWhite
        vehicleInfoView.backgroundColor = UIColor.otgWhite
        vehicleInfoView.layoutCornerRadiusAndShadow()
        vehicleInfoViewBottomConstraint.constant = 0
        rideInfoView.backgroundColor = UIColor.otgWhite
        rideInfoView.layoutCornerRadiusAndShadow()
        rideInfoViewBottomConstraint.constant = 0
        rideInfoView.onHowToTapped = {
            self.perform(segue: StoryboardSegue.Main.fromMapToHowTo)
        }
        
        updateUnlockButton()
    }
    
    private func showVehicleInfo(_ vehicle: VehiclePOI) {
        self.vehicleInfoView.updateContentWith(vehicle)
        self.vehicleInfoViewBottomConstraint.constant = self.vehicleInfoViewBottomToSuperView
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideVehicleInfo() {
        self.vehicleInfoViewBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func showRideInfo() {
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
    
    private func updateUnlockButton() {
        if ongoingRide != nil {
            unlockButton.setTitle("End Ride", for: .normal)
        } else {
            unlockButton.setTitle("Unlock", for: .normal)
        }
    }
    
    private func showCompletedRide(_ ride: Ride) {
        alertMessage("Thanks! Ride summary:\(ride.summary())")
    }
}

// MARK: - Map
extension MapViewController {
    private func setupMapView() {
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
    }
    
    private func addMapMakers(forVehicles vehicles: [Vehicle]) {
        DispatchQueue.main.async {
            // add new item
            let items = vehicles.map { (vehicle) -> VehiclePOI in
                let item = VehiclePOI(vehicle: vehicle)
                
                return item
            }
            self.clusterManager.add(items)
            
            self.clusterManager.cluster()
        }
    }
    
    private func clearMapMakers() {
        DispatchQueue.main.async {
            self.clusterManager.clearItems()
        }
    }
    
    private func drawRoute(forPath path:GMSPath?) {
        if ongoingRidePolyline == nil {
            ongoingRidePolyline = GMSPolyline(path: path)
            ongoingRidePolyline?.strokeWidth = 2
            ongoingRidePolyline?.strokeColor = UIColor.otgPrimary
            ongoingRidePolyline?.map = mapView
        }
        
        ongoingRidePolyline?.path = path
    }
}

// MARK: - Location
extension MapViewController {
    private func setupLocationManager() {
        // request location permisison if needed
        locationManager.delegate = self
        locationManager.distanceFilter = minDistanceFilter
        locationManager.activityType = .fitness
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive), name: UIApplication.didBecomeActiveNotification, object: nil)
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
    
    @objc private func appMovedToBackground() {
        if ongoingRide == nil {
            locationManager.stopUpdatingLocation()
        }
    }
    
    @objc private func appBecameActive() {
        locationManager.startUpdatingLocation()
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
        
        currentLocation = location
        
        let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: streetZoomLevel)
        mapView.animate(to: camera)
        
        // once GPS signal is settled, check if there's an ongoing ride
        loadOngoingRide()
        
        if let currentPath = ongoingRidePath {
            currentPath.add(location.coordinate)
            drawRoute(forPath: currentPath)
        }
        
        if let incrementalPath = incrementalPath {
            incrementalPath.add(location.coordinate)
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.error(error.localizedDescription)
    }
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        deferredSearchTimer?.invalidate()
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        deferredSearchTimer?.invalidate()
        
        deferredSearchTimer = Timer.scheduledTimer(timeInterval: searchDeferring,
                                                   target: self,
                                                   selector: #selector(searchVehicles),
                                                   userInfo: nil,
                                                   repeats: false)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let vehiclePOI = marker.userData as? VehiclePOI {
            logger.debug("Did tap a normal marker for vehicle item \(String(describing: vehiclePOI.vehicle._id))")
            showVehicleInfo(vehiclePOI)
        }
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        hideVehicleInfo()
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
        guard let vehiclePOI = marker.userData as? VehiclePOI else { return }
        
        let powerPercent = vehiclePOI.powerPercent ?? 0
        
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
