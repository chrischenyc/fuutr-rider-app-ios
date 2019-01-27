@IBDesignable

class RidingView: DesignableView {
  @IBOutlet weak var rideInProgressLabel: UILabel!
  @IBOutlet weak var ridingTimeLabel: UILabel!
  @IBOutlet weak var ridingDistanceLabel: UILabel!
  @IBOutlet weak var remainingRangeLabel: UILabel!
  
  @IBOutlet weak var costLabel: UILabel!
  @IBOutlet weak var lockButton: UIButton!
  @IBOutlet weak var endRideButton: UIButton!
  
  var onPauseRide: (()->Void)?
  var onEndRide: (()->Void)?
  var onPauseTimeUp: (()->Void)?
  
  func updateContent(withRide ride: Ride) {
    ridingTimeLabel.text = ride.duration.hhmmssString
    ridingDistanceLabel.text = ride.distance.distanceString
    costLabel.text = ride.totalCost.currencyString
    
    if ride.paused {
      guard let pausedUntil = ride.pausedUntil else { return }
      let remainingPausedTime = Int(pausedUntil.timeIntervalSinceNow)
      
      if remainingPausedTime > 0 {
        logger.debug("pausing ride for \(remainingPausedTime) seconds")
      }
      else {
        self.lockButton.setTitle("Lock", for: .normal)
        self.onPauseTimeUp?()
      }
      
      lockButton.setTitle("Unlock", for: .normal)
    } else {
      lockButton.setTitle("Lock", for: .normal)
    }
  }
  
  override var nibName: String {
    get {
      return "RidingView"
    }
    set {}
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupUI()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  private func setupUI() {
    endRideButton.primaryRed()
    lockButton.primaryRedBasic()
    
    rideInProgressLabel.textColor = UIColor.primaryDarkColor
    remainingRangeLabel.textColor = UIColor.primaryGreyColor
    lockButton.addTarget(self, action: #selector(lock), for: .touchUpInside)
    endRideButton.addTarget(self, action: #selector(endRide), for: .touchUpInside)
  }
  
  @objc private func lock() {
    onPauseRide?()
  }
  
  @objc private func endRide() {
    onEndRide?();
  }
}
