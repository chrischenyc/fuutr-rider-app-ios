//
//  TransactionCell.swift
//  OTGRider
//
//  Copyright © 2019 FUUTR. All rights reserved.
//

class RideFinishedViewController: UIViewController {
  
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var rideUsedTimeLabel: UILabel!
  @IBOutlet weak var rideFinishedTimeLabel: UILabel!
  @IBOutlet weak var rideEndedLabel: UILabel!
  @IBOutlet weak var rideDistanceLabel: UILabel!
  @IBOutlet weak var costLabel: UILabel!
  @IBOutlet weak var shareLabel: UILabel!
  @IBOutlet weak var reportButton: UIButton!
  @IBOutlet weak var continueButton: UIButton!
  
  private let streetZoomLevel: Float = 14.0
  private var ridePolyline: GMSPolyline?
  
  var ride: Ride?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    shareLabel.textColor = UIColor.primaryDarkColor
    rideEndedLabel.textColor = UIColor.primaryGreyColor
    rideFinishedTimeLabel.textColor = UIColor.primaryDarkColor
    
    if let ride = ride {
      updateContent(with: ride, and: currentLocation)
    }
  }
  
  func updateContent(with ride: Ride, and location: CLLocation?) {
    costLabel.text = ride.totalCost.currencyString
    rideUsedTimeLabel.text = ride.duration.hhmmssString
    rideDistanceLabel.text = ride.distance.distanceString
    rideFinishedTimeLabel.text = ride.lockTime?.dateTimeString
    
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
