//
//  HistoryRideViewController.swift
//  FUUTR
//
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Cosmos

class HistoryRideViewController: UIViewController {
  
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var costLabel: UILabel!
  @IBOutlet weak var ratingView: CosmosView!
  @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
  
  var ride: Ride?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // adjust auto-layout to fit everything in iPhone 5 screen
    if UIScreen.main.bounds.height <= 568 {
      mapViewHeightConstraint.constant = 260
    }
    
    mapView.applyTheme()
    
    if let ride = ride {
      costLabel.text = ride.totalCost.priceStringWithoutCurrency
      durationLabel.text = ride.duration.hhmmssString
      distanceLabel.text = ride.distance.distanceString
      title = ride.lockTime?.dateTimeString
      if let rating = ride.rating {
        ratingView.rating = Double(rating)
      }
      
      mapView.drawRouteFor(ride: ride)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let navigationController = segue.destination as? UINavigationController,
      let reportIssueViewController = navigationController.topViewController as? ReportIssueViewController {
      reportIssueViewController.ride = ride
    }
  }
}
