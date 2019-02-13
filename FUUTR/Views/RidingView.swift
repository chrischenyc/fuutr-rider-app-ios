@IBDesignable

class RidingView: DesignableView {
  @IBOutlet weak var rideInProgressLabel: UILabel!
  @IBOutlet weak var ridingTimeLabel: UILabel!
  @IBOutlet weak var ridingDistanceLabel: UILabel!
  @IBOutlet weak var remainingRangeLabel: UILabel!
  
  @IBOutlet weak var costLabel: UILabel!
  @IBOutlet weak var lockButton: UIButton!
  @IBOutlet weak var endRideButton: UIButton!
  @IBOutlet weak var scooterIsLockedLabel: UILabel!
  
  var onPauseRide: (()->Void)?
  var onResumeRide: (()->Void)?
  var onEndRide: (()->Void)?
  var onPauseTimeUp: (()->Void)?
  
  var ride: Ride?
  
  func updateContent(withRide ride: Ride) {
    self.ride = ride
    ridingTimeLabel.text = ride.duration.hhmmssString
    ridingDistanceLabel.text = ride.distance.distanceString
    remainingRangeLabel.text = ride.getRemainingRange().distanceString
    costLabel.text = ride.totalCost.priceString
    
    if ride.paused {
      guard let pausedUntil = ride.pausedUntil else { return }
      let remainingPausedTime = Int(pausedUntil.timeIntervalSinceNow)
      
      if remainingPausedTime <= 0 {
        lockButton.setTitle("Lock", for: .normal)
        onPauseTimeUp?()
      }
      else {
        lockButton.setTitle("Unlock", for: .normal)
        scooterIsLockedLabel.isHidden = false
      }
    } else {
      lockButton.setTitle("Lock", for: .normal)
      scooterIsLockedLabel.isHidden = true
    }
  }
  
  override var nibName: String {
    get {
      return "RidingView"
    }
    set {}
  }
  
  @IBAction func lock(_ sender: Any) {
    guard let ride = self.ride else { return }
    if ride.paused {
      onResumeRide?()
    } else {
      onPauseRide?()
    }
  }
  
  @IBAction func endRide(_ sender: Any) {
    onEndRide?();
  }
}
