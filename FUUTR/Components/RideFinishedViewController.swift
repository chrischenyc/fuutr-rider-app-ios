//
//  TransactionCell.swift
//  FUUTR
//
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Cosmos

class RideFinishedViewController: UIViewController {
  
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var rideUsedTimeLabel: UILabel!
  @IBOutlet weak var rideDistanceLabel: UILabel!
  @IBOutlet weak var costLabel: UILabel!
  @IBOutlet weak var ratingView: CosmosView!
  @IBOutlet weak var reportButton: UIButton!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var socialAndButtonVerticalSpacing: NSLayoutConstraint!
  
  private let streetZoomLevel: Float = 14.0
  private var ridePolyline: GMSPolyline?
  
  var ride: Ride?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // adjust auto-layout to fit everything in iPhone 5 screen
    if UIScreen.main.bounds.height <= 568 {
      mapViewHeightConstraint.constant = 200
      socialAndButtonVerticalSpacing.constant = 8
    }
    
    if let ride = ride {
      updateContent(with: ride, and: currentLocation)
    }
  }
  
  func updateContent(with ride: Ride, and location: CLLocation?) {
    costLabel.text = ride.totalCost.currencyString
    rideUsedTimeLabel.text = ride.duration.hhmmssString
    rideDistanceLabel.text = ride.distance.distanceString
    title = ride.lockTime?.dateTimeString
    
    if let location = location {
      let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: streetZoomLevel)
      mapView.animate(to: camera)
      mapView.applyTheme(currentLocation: location)
    }
    
    if let encodedPath = ride.encodedPath, let decodedPath = GMSMutablePath(fromEncodedPath: encodedPath){
      
      drawRoute(forPath: decodedPath)
    }
  }
  
  private func drawRoute(forPath path: GMSPath?) {
    ridePolyline = GMSPolyline(path: path)
    ridePolyline?.strokeWidth = 4
    ridePolyline?.strokeColor = UIColor.primaryRedColor
    ridePolyline?.map = mapView
  }
  
  @IBAction func continueButtonTapped(_ sender: Any) {
    // TODO: submit ride review
    
    performSegue(withIdentifier: R.segue.rideFinishedViewController.unwindToHome, sender: nil)
  }
}
