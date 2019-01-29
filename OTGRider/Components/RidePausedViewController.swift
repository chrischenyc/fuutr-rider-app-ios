protocol RidePausedDelegate: AnyObject {
  func rideShouldResume()
  func rideShouldEnd()
}

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
  
  weak var delegate: RidePausedDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
  }
  
  func updateContent(with ride: Ride) {
    ridingTimeLabel.text = ride.duration.hhmmssString
    ridingDistanceLabel.text = ride.distance.distanceString
    costLabel.text = ride.totalCost.currencyString
    remainingRangeLabel.text = ride.getRemainingRange().distanceString
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
    unlockButton.addTarget(self, action: #selector(resume), for: .touchUpInside)
    endRideButton.addTarget(self, action: #selector(endRide), for: .touchUpInside)
  }
  
  @objc private func close() {
    self.dismiss(animated: true, completion: nil)
  }
  
  @objc private func resume() {
    self.dismiss(animated: true, completion: { [weak self] in
      self?.delegate?.rideShouldResume()
    })
  }
  
  @objc private func endRide() {
    self.alertMessage(title: "Are you sure you want to end the ride?",
                      message: "",
                      positiveActionButtonTitle: "Yes, end ride",
                      positiveActionButtonTapped: {
                        self.dismiss(animated: true, completion: { [weak self] in
                          self?.delegate?.rideShouldEnd()
                        })
    },
                      negativeActionButtonTitle: "No, keep riding")
  }
}
