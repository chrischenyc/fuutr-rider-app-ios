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
    private let streetZoomLevel: Float = 14.0
    private let minDistanceFilter: CLLocationDistance = 3
    private var zonePolygons: [(Zone, GMSPolygon)] = []
    
    private var searchAPITask: URLSessionTask?
    private var rideAPITask: URLSessionTask?
    private var vehicleAPITask: URLSessionTask?
    private var userAPITask: URLSessionTask?
    private var zoneAPITask: URLSessionTask?
    
    private var deferredSearchTimer: Timer?     // a new round of search API will be fired unless time gets invalidated
    private let searchDeferring: TimeInterval = 1.5
    private var rideLocalUpdateTimer: Timer?    // periodically update duration, distance, route
    private let localUpdateFrequency: TimeInterval = 1
    private var rideServerUpdateTimer: Timer?   // periodically report travelled coordinates to server
    private let serverUpdateFrequency: TimeInterval = 10
    private var serverUpdateThreshhold: CLLocationDistance = 10    // the minimum travel distance for a new server update
    
    private var didLoadOngoingRide: Bool = false
    
    private var currentUser: User?
    
    var ongoingRide: Ride? {
      didSet {
        if let ongoingRide = ongoingRide {
           ridingView.updateContent(withRide: ongoingRide)
        }
        
        if ongoingRide != oldValue {
           updateUnlockView()
        }
      }
    }
    
    private var ongoingRidePath: GMSMutablePath?    // to track travelled distance and to draw route
    private var ongoingRidePolyline: GMSPolyline?
    private var incrementalPath: GMSMutablePath?    // to report to server for the new segment
  
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var unlockButton: UIButton!
    
  @IBOutlet weak var ridingView: RidingView!
  @IBOutlet weak var unlockView: UIView!
  @IBOutlet weak var vehicleInfoView: VehicleInfoView!
  @IBOutlet weak var vehicleReservedInfoView: VehicleReservedInfoView!
  // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupMapView()
        setupLocationManager()
        getCurrentUser()
        getZones()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // animate out vehicle banner before leaving
        hideVehicleInfo()
      
      // pass through ended Ride object for feature photo uploading API calling
      if let endRidePhotoViewController = segue.destination as? EndRidePhotoViewController,
        let ride = sender as? Ride {
        endRidePhotoViewController.ride = ride
      }
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
        else if let endRidePhotoViewController = sourceViewController as? EndRidePhotoViewController,
          let unwindSegueWithCompletion = unwindSegue as? UIStoryboardSegueWithCompletion {
          // user finishes uploading complete ride photo
          // present ride summary
          unwindSegueWithCompletion.completion = {
            self.showRideSummary(endRidePhotoViewController.ride)
          }
      }
    }
    
    @objc private func unlock() {
      if let viewController = UIStoryboard(name: "ScanUnlock", bundle: nil).instantiateInitialViewController() as? UINavigationController,
         let unlockVC = viewController.topViewController as? UnlockViewController {
          self.presentFullScreen(viewController)
          unlockVC.delegate = self
      }
    }
}

// MARK: - scan or input to unlock
extension MapViewController: UnlockDelegate {
  func vehicleUnlocked(with ride: Ride) {
    self.startTrackingRide(ride)
    showHowToRide()
  }
}

// MARK: - Ride Tracking
extension MapViewController {
    private func startTrackingRide(_ ride: Ride) {
        ongoingRide = ride
        
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
        
        rideLocalUpdateTimer?.invalidate()
        rideServerUpdateTimer?.invalidate()
        
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
        ride.distance = ongoingRidePath?.length(of: GMSLengthKind.geodesic) ?? 0
        
        self.ongoingRide = ride
    }
}

// MARK: - API
extension MapViewController {
    @objc private func searchVehicles() {
        // pause new vehicles search while user is during a ride
        guard ongoingRide == nil else { return }
        
        searchAPITask?.cancel()
        
        searchAPITask = VehicleService.search(latitude: mapView.getCenterCoordinate().latitude,
                                              longitude: mapView.getCenterCoordinate().longitude,
                                              radius: mapView.getRadius(),
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
    
    private func refreshOngoingRide() {
        guard let id = ongoingRide?.id else { return }
        
        rideAPITask?.cancel()
        
        rideAPITask = RideService.getRide(id, completion: { [weak self] (ride, error) in
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
    
    private func endRide() {
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
                                                    if error!.localizedDescription == "no-parking" {
                                                        self?.showNoParkingZoneError()
                                                    }
                                                    else {
                                                        self?.alertError(error!)
                                                    }
                                                    return
                                                }
                                                
                                                guard let ride = ride else {
                                                    self?.alertMessage(message: L10n.kOtherError)
                                                    return
                                                }
                                                
                                                self?.takePhotoForCompletedRide(ride)
                                                
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
    
    private func pauseRide() {
        guard let rideId = ongoingRide?.id else { return }
        
        rideAPITask?.cancel()
        
        rideAPITask = RideService.pause(rideId: rideId) { [weak self] (ride, error) in
            if error != nil {
                logger.error(error)
                
                if error!.localizedDescription == "no-parking" {
                    self?.showNoParkingZoneError()
                }
                else {
                    self?.alertError(error!)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                self?.ongoingRide = ride
                self?.updateRideLocally()
            }
        }
    }
    
    private func resumeRide() {
        guard let rideId = ongoingRide?.id else { return }
        
        rideAPITask?.cancel()
        
        rideAPITask = RideService.resume(rideId: rideId) { [weak self] (ride, error) in
            if error != nil {
                logger.error(error)
                self?.alertError(error!)
                return
            }
            
            DispatchQueue.main.async {
                self?.ongoingRide = ride
                self?.updateRideLocally()
            }
        }
    }
  
    private func cancelVehicleReservation(_ vehicle: Vehicle) {
      self.toggleVehicleReservation(id: vehicle._id, state: false)
    }
    
    private func reserveVehicle(_ vehicle: Vehicle) {
      self.toggleVehicleReservation(id: vehicle._id, state: true)
    }
  
    private func toggleVehicleReservation(id: String, state: Bool) {
      // user can't reserve a vehicle during a ride
      guard ongoingRide == nil else { return }
      
      vehicleAPITask?.cancel()
      
      vehicleAPITask = VehicleService.reserve(_id: id, reserve: state, completion: { [weak self] (vehicle, error) in
        guard error == nil else {
          DispatchQueue.main.async {
            self?.flashErrorMessage(error?.localizedDescription)
          }
          
          return
        }
        
        if let vehicle = vehicle {
          DispatchQueue.main.async {
            // refresh vehicle info banner
            self?.updateVehicleInfo(vehicle)
            
            // refresh map search
            self?.searchVehicles()
          }
        }
        
        self?.getCurrentUser()
      })
    }
    
    private func getCurrentUser() {
        userAPITask?.cancel()
        userAPITask = UserService.getProfile { (user, error) in
            self.currentUser = user
        }
    }
    
    private func getZones() {
        zoneAPITask?.cancel()
        zoneAPITask = ZoneService.search({ [weak self] (zones, error) in
            guard error == nil else {
                logger.error(error?.localizedDescription)
                return
            }
            
            guard let zones = zones else {
                return
            }
            
            self?.addMapZones(zones)
        })
    }
}

// MARK: - UI
extension MapViewController {
    private func setupUI() {
        sideMenuButton.backgroundColor = UIColor.clear
        
        unlockView.layoutCornerRadiusMask(corners: [UIRectCorner.topLeft, UIRectCorner.topRight])
        unlockButton.primaryRed()
        unlockButton.addTarget(self, action: #selector(unlock), for: .touchUpInside)
      
        vehicleInfoView.layoutCornerRadiusMask(corners: [UIRectCorner.topLeft, UIRectCorner.topRight])
        vehicleInfoView.onReserve = { [weak self] (vehicle) in
            self?.alertMessage(title: "Reserve Scooter",
                               message: "You'll have 15 minutes to scan/enter code the scooter. After that, you'll lose the reservation.",
                            positiveActionButtonTitle: "OK",
                            positiveActionButtonTapped: {
                              self?.reserveVehicle(vehicle)
                            },
                            negativeActionButtonTitle: "Cancel")
        }
      
        vehicleInfoView.onClose = { [weak self] in
          self?.hideVehicleInfo()
        }
      
        vehicleInfoView.onScan = { [weak self] in
          self?.unlock()
        }
      
        vehicleReservedInfoView.layoutCornerRadiusMask(corners: [UIRectCorner.topLeft, UIRectCorner.topRight])
        vehicleReservedInfoView.onScan = { [weak self] in
          self?.unlock()
        }
      
        vehicleReservedInfoView.onCancel = { [weak self] (vehicle) in
            self?.alertMessage(title: "Are you sure you want to cancel the reservation?",
                               message: "You won't be able to reserve again for 15 minutes.",
                             positiveActionButtonTitle: "Keep reservation",
                             positiveActionButtonTapped: {},
                             negativeActionButtonTitle: "Cancel reservation",
                             negativeActionButtonTapped: {
                                self?.cancelVehicleReservation(vehicle)
                             })
        }
      
        vehicleReservedInfoView.onReserveTimeUp = { [weak self] in
           DispatchQueue.main.async {
              self?.searchVehicles()
           }
        }
      
        ridingView.layoutCornerRadiusMask(corners: [UIRectCorner.topLeft, UIRectCorner.topRight])
        ridingView.onPauseRide = {
          guard let paused = self.ongoingRide?.paused else { return }

          if paused {
              self.resumeRide()
          } else {
              self.pauseRide()
          }
        }
      
        ridingView.onEndRide = {
          self.alertMessage(title: "Are you sure you want to end the ride?",
                            message: "",
                            positiveActionButtonTitle: "Yes, end ride",
                            positiveActionButtonTapped: {
                              self.endRide()
                            },
                            negativeActionButtonTitle: "No, keep riding")
        }
        ridingView.onPauseTimeUp = {
          self.refreshOngoingRide()
        }
      
        updateUnlockView()
    }
  
    private func showHowToRide() {
      let viewController = UIStoryboard(name: "HowToRide", bundle: nil).instantiateViewController(withIdentifier: "HowToRide") as! HowToRideViewController
      self.presentFullScreen(viewController)
    }
    
    private func showVehicleInfo(_ vehicle: Vehicle) {
      self.updateVehicleInfo(vehicle)
      self.unlockView.isHidden = true
    }
    
    private func hideVehicleInfo() {
      self.vehicleInfoView.isHidden = true
      self.vehicleReservedInfoView.isHidden = true
      self.unlockView.isHidden = false
    }
  
    private func updateVehicleInfo(_ vehicle: Vehicle) {
      if vehicle.reserved {
        self.vehicleReservedInfoView.updateContentWith(vehicle)
        self.vehicleReservedInfoView.isHidden = false
        self.vehicleInfoView.isHidden = true
      } else {
        self.vehicleInfoView.updateContentWith(vehicle)
        self.vehicleInfoView.isHidden = false
        self.vehicleReservedInfoView.isHidden = true
      }
    }
    
    private func updateUnlockView() {
      if ongoingRide != nil {
        ridingView.isHidden = false
        unlockView.isHidden = true
        vehicleInfoView.isHidden = true
        vehicleReservedInfoView.isHidden = true
      } else {
        ridingView.isHidden = true
        unlockView.isHidden = false
      }
    }
    
    private func showRideSummary(_ ride: Ride) {
        alertMessage(message: "Thanks! Ride summary:\(ride.summary())")
    }
  
  private func takePhotoForCompletedRide(_ ride: Ride) {
    perform(segue: StoryboardSegue.Main.showEndRidePhoto, sender: ride)
  }
    
    private func toggleZoneInfo(_ coordinate: CLLocationCoordinate2D) {
        var insideZone: (Zone, GMSPolygon)?
        
        for (zone, polygon) in zonePolygons {
            if let path = polygon.path, GMSGeometryContainsLocation(coordinate, path, true) {
                insideZone = (zone, polygon)
                break
            }
        }
        
        if let (zone, _) = insideZone, let title = zone.title, let message = zone.message {
            let locationMarker = GMSMarker(position: coordinate)
            locationMarker.map = mapView
            locationMarker.appearAnimation = .none
            locationMarker.icon = UIImage(asset: Asset.transparent)
            locationMarker.opacity = 0
            locationMarker.isFlat = true
            locationMarker.title = title
            locationMarker.snippet = message
            mapView.selectedMarker = locationMarker
        }
    }
    
    private func showNoParkingZoneError() {
        self.alertMessage(title: "You are attempting to park the vehicle in an unsafe area",
                           message: "The ride cannot end until it is parked upright in an accepted, safe areea.",
                           image: UIImage(asset: Asset.unsafeParkingPopup),
                           positiveActionButtonTitle: "I will re-park the vehicle")
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
    
    private func addMapZones(_ zones: [Zone]) {
        clearMapZones()
        
        DispatchQueue.main.async { [weak self] in
            for zone in zones {
                let path = GMSMutablePath()
                
                for coordinates in zone.polygon {
                    path.add(CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0]))
                }
                
                // Create the polygon, and assign it to the map.
                var fillColor: UIColor?
                var strokeColor: UIColor?
                
                if !zone.parking {
                    fillColor = UIColor.noParkingZoneFillColor
                    strokeColor = UIColor.noParkingZoneStrokeColor
                }
                else if zone.speedMode == 1 {
                    fillColor = UIColor.lowSpeedZoneFillColor
                    strokeColor = UIColor.lowSpeedZoneStrokeColor
                }
                else if zone.speedMode == 2 {
                    fillColor = UIColor.midSpeedZoneFillColor
                    strokeColor = UIColor.midSpeedZoneStrokeColor
                }
                
                if let fillColor = fillColor, let strokeColor = strokeColor {
                    let polygon = GMSPolygon(path: path)
                    polygon.fillColor = fillColor
                    polygon.strokeColor = strokeColor
                    polygon.strokeWidth = 1
                    polygon.geodesic = true
                    polygon.map = self?.mapView
                    
                    self?.zonePolygons.append((zone, polygon))
                }
            }
        }
    }
    
    private func clearMapZones() {
        DispatchQueue.main.async {
            [weak self] in
            
            guard var zonePolygons = self?.zonePolygons else { return }
            
            for (_, polygon) in zonePolygons {
                polygon.map = nil
            }
            
            zonePolygons.removeAll()
        }
    }
    
    private func addMapMakers(forVehicles vehicles: [Vehicle]) {
        DispatchQueue.main.async {
            // remove existing items
            self.clusterManager.clearItems()
            
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
            ongoingRidePolyline?.strokeWidth = 4
            ongoingRidePolyline?.strokeColor = UIColor.primaryRedColor
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
        alertMessage(title: "Location Service Required",
                     message: "This app needs access to the location service so it can find scooters close to you and track your rides.",
                     positiveActionButtonTitle: "Grant Access",
                     positiveActionButtonTapped: {
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
        })
    }
    
    @objc private func appMovedToBackground() {
        // pause GPS updating if user is not in a ride
        if ongoingRide == nil || ongoingRide!.paused {
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
        
        // center user once the location is captured for the first time
        if currentLocation == nil {
            let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: streetZoomLevel)
            mapView.animate(to: camera)
        }
        currentLocation = location
        
        // once GPS signal is settled, check if there's an ongoing ride
        if ongoingRide == nil && !didLoadOngoingRide {
            loadOngoingRide()
        }
        
        // during a ride
        // update map view and ride path
        if let ongoingRide = ongoingRide, !ongoingRide.paused {
            // keep centring user during an active ride
            let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: streetZoomLevel)
            mapView.animate(to: camera)
            
            if let currentPath = ongoingRidePath {
                currentPath.add(location.coordinate)
                drawRoute(forPath: currentPath)
            }
            
            if let incrementalPath = incrementalPath {
                incrementalPath.add(location.coordinate)
            }
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
            showVehicleInfo(vehiclePOI.vehicle)
        }
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        hideVehicleInfo()
        toggleZoneInfo(coordinate)
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
        
        let powerPercent = vehiclePOI.vehicle.powerPercent ?? 0
        
        if 80...100 ~= powerPercent {
            marker.icon = Asset.scooterPinGreen.image
        } else if 30..<80 ~= powerPercent {
            marker.icon = Asset.scooterPinYellow.image
        } else {
            marker.icon = Asset.scooterPinRed.image
        }
        
    }
}
