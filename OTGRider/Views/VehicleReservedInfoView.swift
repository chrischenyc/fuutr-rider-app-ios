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
  
  var onCancel: ((Vehicle) -> Void)?
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
    
    cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
  }
  
  func updateContentWith(_ vehicle: Vehicle) {
    self.vehicle = vehicle
    scanButton.titleLabel?.textColor = .white
    
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
  
  @objc private func scanButtonTapped() {
    onScan?()
  }
  
  @objc private func cancelButtonTapped() {
    guard let vehicle = vehicle else { return }
    onCancel?(vehicle)
  }
}
