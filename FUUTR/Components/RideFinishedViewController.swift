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
  
  var ride: Ride?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // adjust auto-layout to fit everything in iPhone 5 screen
    if UIScreen.main.bounds.height <= 568 {
      mapViewHeightConstraint.constant = 200
      socialAndButtonVerticalSpacing.constant = 8
    }
    
    mapView.applyTheme()
    
    if let ride = ride {
      costLabel.text = ride.totalCost.currencyString
      rideUsedTimeLabel.text = ride.duration.hhmmssString
      rideDistanceLabel.text = ride.distance.distanceString
      title = ride.lockTime?.dateTimeString
      mapView.drawRouteFor(ride: ride)
    }
  }
  
  @IBAction func continueButtonTapped(_ sender: Any) {
    // TODO: submit ride review
    
    performSegue(withIdentifier: R.segue.rideFinishedViewController.unwindToHome, sender: nil)
  }
}
