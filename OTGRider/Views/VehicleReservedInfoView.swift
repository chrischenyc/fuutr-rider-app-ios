@IBDesignable
class VehicleReservedInfoView: DesignableView {
  
  @IBOutlet weak var scooterReserved: UILabel!
  
  @IBOutlet weak var parkLabel: UILabel!
  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var scanButton: UIButton!
  
  override var nibName: String {
    get {
      return "VehicleReservedInfoView"
    }
    set {}
  }
  
  private var reserveTimer: Timer?
  private var vehicle: Vehicle?
  
  var onCancel: (() -> Void)?
  var onScan: (() -> Void)?
  var onReserveTimeUp: (()->Void)?
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupUI()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  private func setupUI() {
    scanButton.primaryRed()
    cancelButton.primaryRedBasic()
    scooterReserved.textColor = UIColor.primaryDarkColor
    parkLabel.textColor = UIColor.primaryGreyColor
    timerLabel.textColor = UIColor.primaryDarkColor
  }
  
  func updateContentWith(_ vehicle: Vehicle) {
    self.vehicle = vehicle
    scanButton.titleLabel?.textColor = .white
    
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
}
