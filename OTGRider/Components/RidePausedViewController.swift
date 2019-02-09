//
//  TransactionCell.swift
//  OTGRider
//
//  Copyright © 2019 FUUTR. All rights reserved.
//

enum RidePausedViewControllerDismissAction {
  case resumeRide
  case endRide
  case none
}

class RidePausedViewController: UIViewController {
  
  @IBOutlet weak var costLabel: UILabel!
  @IBOutlet weak var ridingTimeLabel: UILabel!
  @IBOutlet weak var ridingDistanceLabel: UILabel!
  @IBOutlet weak var remainingRangeLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var unlockButton: UIButton!
  @IBOutlet weak var endRideButton: UIButton!
  
  var dismissAction: RidePausedViewControllerDismissAction?
  
  func updateContent(with ride: Ride) {
    ridingTimeLabel.text = ride.duration.hhmmssString
    ridingDistanceLabel.text = ride.distance.distanceString
    costLabel.text = ride.totalCost.currencyString
    remainingRangeLabel.text = ride.getRemainingRange().distanceString
    priceLabel.text = "\(ride.pauseMinuteCost.currencyString) per minute"
  }
  
  @objc private func close() {
    dismissAction = .none
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func resumeRide(_ sender: Any) {
    dismissAction = .resumeRide
    performSegue(withIdentifier: R.segue.ridePausedViewController.unwindToHome, sender: nil)
  }
  
  @IBAction func endRide(_ sender: Any) {
    self.alertMessage(title: "Are you sure you want to end the ride?",
                      message: "",
                      positiveActionButtonTitle: "Yes, end ride",
                      positiveActionButtonTapped: {
                        self.dismissAction = .endRide
                        self.performSegue(withIdentifier: R.segue.ridePausedViewController.unwindToHome, sender: nil)
    },
                      negativeActionButtonTitle: "No, keep riding")
  }
}
