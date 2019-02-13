//
//  MainViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 15/10/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import GoogleMaps

class MainViewController: UIViewController {
  
  // ---------- Google Maps ----------
  private let locationManager = CLLocationManager()
  private var clusterManager: GMUClusterManager!
  private let searchingZoomLevel: Float = 15.0
  private let ridingZoomLevel: Float = 18.0
  private let minDistanceFilter: CLLocationDistance = 1
  private var zonePolygons: [(Zone, GMSPolygon)] = []
  private var ongoingRidePath: GMSMutablePath?    // to track travelled distance and to draw route
  private var ongoingRidePolyline: GMSPolyline?
  
  // ---------- API requests ----------
  private var searchAPITask: URLSessionTask?
  private var rideAPITask: URLSessionTask?
  private var vehicleAPITask: URLSessionTask?
  private var userAPITask: URLSessionTask?
  
  // ---------- recurring operations ----------
  private var deferredSearchTimer: Timer?     // new search will be fired unless timer gets invalidated
  private let searchDeferring: TimeInterval = 1.5 // cooling off period in case user moves the map again
  private var ongoingRideRefreshTimer: Timer?    // periodically update duration, distance, route
  
  // ---------- run-time values ----------
  private var didLoadOngoingRide: Bool = false  // after launch, the app would try to load an ongoing ride
  
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
  
  // ---------- IBOutlet ----------
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var sideMenuButton: UIButton!
  
  @IBOutlet weak var unlockInfoView: UnlockInfoView!
  @IBOutlet weak var vehicleInfoView: VehicleInfoView!
  @IBOutlet weak var vehicleReservedInfoView: VehicleReservedInfoView!
  @IBOutlet weak var ridingView: RidingView!
  
  // MARK: - lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupMapView()
    setupLocationManager()
    
    NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let navigationController = segue.destination as? UINavigationController,
      let ridePausedViewController = navigationController.topViewController as? RidePausedViewController,
      let ride = sender as? Ride {
      ridePausedViewController.ride = ride
    }
    
    if let endRidePhotoViewController = segue.destination as? RideParkedPhotoViewController,
      let ride = sender as? Ride {
      endRidePhotoViewController.ride = ride
    }
    
    if let navigationController = segue.destination as? UINavigationController,
      let rideFinishedViewController = navigationController.topViewController as? RideFinishedViewController,
      let ride = sender as? Ride {
      rideFinishedViewController.ride = ride
    }
  }
  
  @objc func applicationDidBecomeActive(_ notification: NSNotification) {
    if currentLocation != nil && deferredSearchTimer == nil {
      search()
    }
  }
  
  // MARK: - user actions
  @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
    let sourceViewController = unwindSegue.source
    
    // unwind from side menu
    if let sideMenuViewController = sourceViewController as? SideMenuViewController,
      let selectedMenuItem = sideMenuViewController.selectedMenuItem,
      let unwindSegueWithCompletion = unwindSegue as? UIStoryboardSegueWithCompletion {
      
      unwindSegueWithCompletion.completion = {
        switch selectedMenuItem {
        case .history:
          self.performSegue(withIdentifier: R.segue.mainViewController.showHistory, sender: nil)
        case .wallet:
          self.performSegue(withIdentifier: R.segue.mainViewController.showAccount, sender: nil)
        case .account:
          self.performSegue(withIdentifier: R.segue.mainViewController.showSettings, sender: nil)
        case .help:
          if let url = URL(string: config.env.helpURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
          
          // in case we need to integrate and present help desk page in app
          // self.perform(segue: StoryboardSegue.Main.showHelp)
        }
        
      }
    }
      // unwind from unlock
    else if let unlockViewController = sourceViewController as? UnlockViewController,
      let unwindSegueWithCompletion = unwindSegue as? UIStoryboardSegueWithCompletion,
      let ride = unlockViewController.ride {
      
      unwindSegueWithCompletion.completion = {
        self.startTrackingRide(ride)
        self.showHowToRide()
      }
      
    }
      // unwind from paused ride
    else if let ridePausedViewController = sourceViewController as? RidePausedViewController,
      let unwindSegueWithCompletion = unwindSegue as? UIStoryboardSegueWithCompletion,
      let dismissAction = ridePausedViewController.dismissAction {
      
      unwindSegueWithCompletion.completion = {
        switch dismissAction {
        case .resumeRide:
          self.resumeRide()
          
        case .endRide:
          self.endRide()
        }
      }
      
    }
    
  }
  
  private func unlock() {
    performSegue(withIdentifier: R.segue.mainViewController.showUnlock, sender: nil)
  }
}

// MARK: - Ride Tracking
extension MainViewController {
  private func startTrackingRide(_ ride: Ride) {
    ongoingRide = ride
    
    ongoingRideRefreshTimer?.invalidate()
    ongoingRideRefreshTimer = Timer.scheduledTimer(timeInterval: 1,
                                                   target: self,
                                                   selector: #selector(self.updateRideLocally),
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
    
    if let currentLocation = currentLocation {
      ongoingRidePath?.add(currentLocation.coordinate)
    }
    
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.pausesLocationUpdatesAutomatically = false
    
    // do not show vehicles during riding
    clearMapMakers()
    
    // zoom in map during ride
    if let currentLocation = currentLocation {
      let camera = GMSCameraPosition.camera(withTarget: currentLocation.coordinate, zoom: ridingZoomLevel)
      mapView.animate(to: camera)
    }
  }
  
  private func stopTrackingRide() {
    ongoingRide = nil
    
    ongoingRideRefreshTimer?.invalidate()
    
    ongoingRidePath = nil
    ongoingRidePolyline?.map = nil
    ongoingRidePolyline = nil
    
    locationManager.allowsBackgroundLocationUpdates = false
    locationManager.pausesLocationUpdatesAutomatically = true
    
    // zoom out map after ride
    if let currentLocation = currentLocation {
      let camera = GMSCameraPosition.camera(withTarget: currentLocation.coordinate, zoom: searchingZoomLevel)
      mapView.animate(to: camera)
    }
    
    search()
  }
  
  @objc private func updateRideLocally() {
    guard var ride = ongoingRide else { return }
    
    ride.refresh()
    ride.distance = ongoingRidePath?.length(of: GMSLengthKind.geodesic) ?? 0
    
    ongoingRide = ride
  }
}

// MARK: - API
extension MainViewController {
  @objc private func search() {
    // stop searching while in an active ride
    guard ongoingRide == nil || ongoingRide!.paused else { return }
    
    searchAPITask?.cancel()
    
    searchAPITask = SearchService.search(coordinates: mapView.getCenterCoordinate(),
                                         radius: mapView.getRadius(),
                                         completion: { [weak self] (vehicles, zones, error) in
                                          
                                          DispatchQueue.main.async {
                                            guard error == nil else {
                                              logger.error(error?.localizedDescription)
                                              return
                                            }
                                            
                                            self?.addMapMakersFor(vehicles)
                                            self?.addMapPolygonsFor(zones)
                                          }
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
    
    rideAPITask?.cancel()
    
    showLoading()
    
    rideAPITask = RideService.finish(rideId: id, completion: { [weak self] (ride, error) in
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
          self?.alertMessage(message: R.string.localizable.kOtherError())
          return
        }
        
        self?.performSegue(withIdentifier: R.segue.mainViewController.showRideParkedPhoto, sender: ride)
        
        self?.stopTrackingRide()
      }
    })
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
        if let ride = self?.ongoingRide {
          self?.performSegue(withIdentifier: R.segue.mainViewController.showRidePaused, sender: ride)
        }
        self?.search()
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
        self?.clearMapMakers()
      }
    }
  }
  
  private func toggleVehicleReservation(id: String, reserve: Bool) {
    // user can't reserve a vehicle during a ride
    guard ongoingRide == nil else { return }
    
    vehicleAPITask?.cancel()
    
    vehicleAPITask = VehicleService.reserve(_id: id, reserve: reserve, completion: { [weak self] (vehicle, error) in
      
      DispatchQueue.main.async {
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        if let vehicle = vehicle {
          self?.updateVehicleInfo(vehicle)
          
          // refresh map search
          self?.search()
        }
        
      }
    })
  }
  
  private func getUser() {
    userAPITask?.cancel()
    
    userAPITask = UserService.getProfile({ (user, error) in
      guard error == nil else {
        logger.error("Couldn't get user profile: \(error!.localizedDescription)")
        return
      }
      
      currentUser = user
    })
  }
  
}

// MARK: - UI
extension MainViewController {
  override func viewDidLayoutSubviews() {
    unlockInfoView.layoutCornerRadiusMask(corners: [UIRectCorner.topLeft, UIRectCorner.topRight])
    vehicleInfoView.layoutCornerRadiusMask(corners: [UIRectCorner.topLeft, UIRectCorner.topRight])
    vehicleReservedInfoView.layoutCornerRadiusMask(corners: [UIRectCorner.topLeft, UIRectCorner.topRight])
    ridingView.layoutCornerRadiusMask(corners: [UIRectCorner.topLeft, UIRectCorner.topRight])
  }
  
  private func setupUI() {
    if let remoteConfig = remoteConfig {
      unlockInfoView.priceLabel.text = "\(remoteConfig.unlockCost.currencyString) to unlock, \(remoteConfig.rideMinuteCost.currencyString) per minute"
    }
    
    unlockInfoView.onFindMe = { [weak self] in
      if let location = currentLocation, let searchingZoomLevel = self?.searchingZoomLevel {
        let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: searchingZoomLevel)
        self?.mapView.animate(to: camera)
      }
    }
    
    unlockInfoView.onScan = { [weak self] in
      self?.unlock()
    }
    
    vehicleInfoView.onReserve = { [weak self] (vehicle) in
      self?.alertMessage(title: "Reserve Scooter",
                         message: "You'll have 15 minutes to scan/enter code the scooter. After that, you'll lose the reservation.",
                         positiveActionButtonTitle: "OK",
                         positiveActionButtonTapped: {
                          self?.toggleVehicleReservation(id: vehicle._id, reserve: true)
      },
                         negativeActionButtonTitle: "Cancel")
    }
    
    vehicleInfoView.onClose = { [weak self] in
      self?.hideVehicleInfo()
    }
    
    vehicleInfoView.onScan = { [weak self] in
      self?.unlock()
    }
    
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
                          self?.toggleVehicleReservation(id: vehicle._id, reserve: false)
      })
    }
    
    vehicleReservedInfoView.onReserveTimeUp = { [weak self] in
      DispatchQueue.main.async {
        self?.search()
      }
    }
    
    ridingView.onPauseRide = { [weak self] in
      self?.alertMessage(title: "Are you sure you want to lock the scooter?",
                         message: "You'll be charged $0.15c per minute when scooter is locked.",
                         positiveActionButtonTitle: "Yes, lock it",
                         positiveActionButtonTapped: {
                          self?.pauseRide()
      },
                         negativeActionButtonTitle: "No, keep riding")
    }
    
    ridingView.onResumeRide = { [weak self] in
      self?.resumeRide()
    }
    
    ridingView.onEndRide = { [weak self] in
      self?.alertMessage(title: "Are you sure you want to end the ride?",
                         message: "",
                         positiveActionButtonTitle: "Yes, end ride",
                         positiveActionButtonTapped: {
                          self?.endRide()
      },
                         negativeActionButtonTitle: "No, keep riding")
    }
    ridingView.onPauseTimeUp = { [weak self] in
      self?.refreshOngoingRide()
    }
    
    updateUnlockView()
  }
  
  private func showHowToRide() {
    performSegue(withIdentifier: R.segue.mainViewController.showHowToRide, sender: nil)
  }
  
  private func showVehicleInfo(_ vehicle: Vehicle) {
    // TODO: add show/hide transition animation
    updateVehicleInfo(vehicle)
    unlockInfoView.isHidden = true
    
    if let currentLocation = currentLocation, let latitude = vehicle.latitude, let longitude = vehicle.longitude {
      mapView.drawWalkingRoute(from: currentLocation.coordinate,
                               to: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    }
  }
  
  private func hideVehicleInfo() {
    // TODO: show/hide transition animation
    vehicleInfoView.isHidden = true
    vehicleReservedInfoView.isHidden = true
    unlockInfoView.isHidden = false
    
    mapView.clearWalkingRoute()
  }
  
  private func updateVehicleInfo(_ vehicle: Vehicle) {
    if vehicle.reserved {
      vehicleReservedInfoView.updateContentWith(vehicle)
      vehicleReservedInfoView.isHidden = false
      vehicleInfoView.isHidden = true
    } else {
      vehicleInfoView.updateContentWith(vehicle)
      vehicleInfoView.isHidden = false
      vehicleReservedInfoView.isHidden = true
    }
  }
  
  private func updateUnlockView() {
    if ongoingRide != nil {
      ridingView.isHidden = false
      unlockInfoView.isHidden = true
      vehicleInfoView.isHidden = true
      vehicleReservedInfoView.isHidden = true
    } else {
      ridingView.isHidden = true
      unlockInfoView.isHidden = false
    }
  }
  
  private func showNoParkingZoneError() {
    alertMessage(title: "You are attempting to park the vehicle in an unsafe area",
                 message: "The ride cannot end until it is parked upright in an accepted, safe areea.",
                 image: R.image.unsafeParkingPopup(),
                 positiveActionButtonTitle: "I will re-park the vehicle")
  }
}

// MARK: - Map
extension MainViewController {
  private func setupMapView() {
    mapView.delegate = self
    mapView.applyTheme()
    
    // Set up the cluster manager with the supplied icon generator and renderer.
    // https://developers.google.com/maps/documentation/ios-sdk/utility/marker-clustering
    
    // TODO: need to generate cluster images
    let iconGenerator = GMUDefaultClusterIconGenerator(buckets: [10, 20, 50, 100],
                                                       backgroundImages: [R.image.clusterPin()!,
                                                                          R.image.clusterPin()!,
                                                                          R.image.clusterPin()!,
                                                                          R.image.clusterPin()!])
    let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
    let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
    renderer.delegate = self
    clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
    clusterManager.setDelegate(self, mapDelegate: self)
  }
  
  private func addMapPolygonsFor(_ zones: [Zone]) {
    // clear existing polygons
    for (_, polygon) in zonePolygons {
      polygon.map = nil
    }
    zonePolygons.removeAll()
    
    // add new polygons
    for zone in zones {
      let polygon = GMSPolygon(zone: zone)
      polygon.map = mapView
      zonePolygons.append((zone, polygon))
    }
  }
  
  private func addMapMakersFor(_ vehicles: [Vehicle]) {
    // remove existing items
    clearMapMakers()
    
    // add new item
    let items = vehicles.map { (vehicle) -> VehiclePOI in
      let item = VehiclePOI(vehicle: vehicle)
      
      return item
    }
    clusterManager.add(items)
    
    clusterManager.cluster()
  }
  
  private func clearMapMakers() {
    clusterManager.clearItems()
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
      locationMarker.icon = R.image.transparent()
      locationMarker.opacity = 0
      locationMarker.isFlat = true
      locationMarker.title = title
      locationMarker.snippet = message
      mapView.selectedMarker = locationMarker
    }
  }
}

// MARK: - Location
extension MainViewController {
  private func setupLocationManager() {
    // request location permisison if needed
    locationManager.delegate = self
    locationManager.distanceFilter = minDistanceFilter
    locationManager.activityType = .otherNavigation
    
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
extension MainViewController: CLLocationManagerDelegate {
  
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
      let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: searchingZoomLevel)
      mapView.animate(to: camera)
    }
    currentLocation = location
    mapView.applyTheme()
    
    // once GPS signal is settled, check if there's an ongoing ride
    if ongoingRide == nil && !didLoadOngoingRide {
      loadOngoingRide()
    }
    
    // during a ride, update map view and ride path
    if let ongoingRide = ongoingRide, !ongoingRide.paused {
      // keep centring user during an active ride
      // TODO: sync map heading direction with user's
      let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: ridingZoomLevel)
      mapView.animate(to: camera)
      
      if let currentPath = ongoingRidePath {
        currentPath.add(location.coordinate)
        drawRoute(forPath: currentPath)
      }
    }
  }
  
  // Handle location manager errors.
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    logger.error(error.localizedDescription)
  }
}

// MARK: - GMSMapViewDelegate
extension MainViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    deferredSearchTimer?.invalidate()
  }
  
  func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
    
  }
  
  func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    deferredSearchTimer?.invalidate()
    
    deferredSearchTimer = Timer.scheduledTimer(timeInterval: searchDeferring,
                                               target: self,
                                               selector: #selector(search),
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
extension MainViewController: GMUClusterManagerDelegate {
  func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
    let newCamera = GMSCameraPosition.camera(withTarget: cluster.position, zoom: mapView.camera.zoom + 1)
    mapView.animate(to: newCamera)
    
    return true
  }
}

// MARK: - GMUClusterRendererDelegate
extension MainViewController: GMUClusterRendererDelegate {
  func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
    guard let vehiclePOI = marker.userData as? VehiclePOI else { return }
    
    let powerPercent = vehiclePOI.vehicle.powerPercent ?? 0
    
    if (ongoingRide?.paused ?? false) {
      marker.icon = R.image.scooterPinLockedGreen()
    } else {
      if 80...100 ~= powerPercent {
        marker.icon = R.image.scooterPinGreen()
      } else if 30..<80 ~= powerPercent {
        marker.icon = R.image.scooterPinYellow()
      } else {
        marker.icon = R.image.scooterPinRed()
      }
    }
  }
}
