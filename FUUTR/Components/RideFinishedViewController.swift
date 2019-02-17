//
//  RideFinishedViewController.swift
//  FUUTR
//
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Cosmos

class RideFinishedViewController: UIViewController {
  
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var costLabel: UILabel!
  @IBOutlet weak var ratingView: CosmosView!
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
      costLabel.text = ride.totalCost.priceStringWithoutCurrency
      durationLabel.text = ride.duration.hhmmssString
      distanceLabel.text = ride.distance.distanceString
      title = ride.lockTime?.dateTimeString
      mapView.drawRouteFor(ride: ride)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let navigationController = segue.destination as? UINavigationController,
      let reportIssueViewController = navigationController.topViewController as? ReportIssueViewController {
      reportIssueViewController.ride = ride
    }
  }
  
  @IBAction func continueButtonTapped(_ sender: Any) {
    // TODO: submit ride review
    
    performSegue(withIdentifier: R.segue.rideFinishedViewController.unwindToHome, sender: nil)
  }
}
