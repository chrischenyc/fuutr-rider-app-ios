class RidePausedViewController: UIViewController {
  
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var rideInProgressLabel: UILabel!
  @IBOutlet weak var costLabel: UILabel!
  @IBOutlet weak var ridingTimeLabel: UILabel!
  @IBOutlet weak var ridingDistanceLabel: UILabel!
  @IBOutlet weak var remainingRangeLabel: UILabel!
  @IBOutlet weak var scooterIsLockedLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var unlockButton: UIButton!
  @IBOutlet weak var endRideButton: UIButton!
  
  var ride: Ride!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
  }
  
  private func setupUI() {
    rideInProgressLabel.textColor = UIColor.primaryDarkColor
    costLabel.textColor = UIColor.primaryGreyColor
    remainingRangeLabel.textColor = UIColor.primaryGreyColor
    scooterIsLockedLabel.textColor = UIColor.primaryDarkColor
    priceLabel.textColor = UIColor.primaryGreyColor
    unlockButton.primaryRed()
    endRideButton.primaryRedBasic()
    
    closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    unlockButton.addTarget(self, action: #selector(unlock), for: .touchUpInside)
    endRideButton.addTarget(self, action: #selector(endRide), for: .touchUpInside)
    
    ridingTimeLabel.text = ride.duration.hhmmssString
    ridingDistanceLabel.text = ride.distance.distanceString
    costLabel.text = ride.totalCost.currencyString
  }
  
  @objc private func close() {
    self.dismiss(animated: true, completion: nil)
  }
  
  @objc private func unlock() {
    
  }
  
  @objc private func endRide() {
    
  }
}
