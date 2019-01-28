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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    continueButton.primaryRed()
    reportButton.primaryDarkBasic()

    shareLabel.textColor = UIColor.primaryDarkColor
    rideEndedLabel.textColor = UIColor.primaryGreyColor
    rideFinishedTimeLabel.textColor = UIColor.primaryDarkColor
    
    continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
  }
  
  func updateContent(with ride: Ride) {
    costLabel.text = ride.totalCost.currencyString
    rideUsedTimeLabel.text = ride.duration.hhmmssString
    rideDistanceLabel.text = ride.distance.distanceString
    rideFinishedTimeLabel.text = ride.lockTime?.dateTimeString
  }
  
  @objc private func continueButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }
}
