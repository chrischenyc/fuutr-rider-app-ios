@IBDesignable
class VehicleReservedInfoView: DesignableView {
  
  @IBOutlet weak var scooterReserved: UILabel!
  
  @IBOutlet weak var parkLabel: UILabel!
  @IBOutlet weak var timerLabel: UILabel!
  
  override var nibName: String {
    get {
      return "VehicleReservedInfoView"
    }
    set {}
  }
  
  private var reserveTimer: Timer?
  private var vehicle: Vehicle?
  
  var onCancel: ((Vehicle) -> Void)?
  var onScan: (() -> Void)?
  var onReserveTimeUp: (()->Void)?
  
  func updateContentWith(_ vehicle: Vehicle) {
    self.vehicle = vehicle
    
    if let address = vehicle.address {
      parkLabel.text = address
    }
    else {
      parkLabel.text = "--"
    }
    
    if vehicle.reserved {
      guard let reservedUntil = vehicle.reservedUntil else { return }
      
      timerLabel.text = calculateTimeString(reservedUntil: reservedUntil)
      
      // create timer to count down
      reserveTimer?.invalidate()
      
      reserveTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (timer) in
        self?.timerLabel.text = self?.calculateTimeString(reservedUntil: reservedUntil)
        
        let remainingReservedTime = Int(reservedUntil.timeIntervalSinceNow)
        if remainingReservedTime <= 0 {
          self?.reserveTimer?.invalidate()
          self?.onReserveTimeUp?()
        }
      })
    } else {
      reserveTimer?.invalidate()
    }
  }
  
  private func calculateTimeString(reservedUntil: Date) -> String {
    let remainingReservedTime = Int(reservedUntil.timeIntervalSinceNow)
    
    if remainingReservedTime > 0 {
      return reservedUntil.timeIntervalSinceNow.hhmmssString
    } else {
      return ""
    }
  }
  
  @IBAction func scanButtonTapped(_ sender: Any) {
    onScan?()
  }
  
  @IBAction func cancelButtonTapped(_ sender: Any) {
    guard let vehicle = vehicle else { return }
    onCancel?(vehicle)
  }
}
