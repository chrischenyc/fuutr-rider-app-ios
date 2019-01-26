@IBDesignable
class VehicleInfoView: DesignableView {
  
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var parkedAt: UILabel!
  @IBOutlet weak var parkedLabel: UILabel!
  
  @IBOutlet weak var range: UILabel!
  @IBOutlet weak var rangeLabel: UILabel!
  
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var reserveButton: UIButton!
  @IBOutlet weak var scanButton: UIButton!
  
  @IBOutlet weak var waitToReserveAgainLabel: UILabel!
  
  @IBOutlet weak var batteryImageView: UIImageView!
  
  override var nibName: String {
    get {
      return "VehicleInfoView"
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
  
  private var reserveTimer: Timer?
  private var vehicle: Vehicle?
  
  var onReserve: ((Vehicle)-> Void)?
  var onClose: (() -> Void)?
  var onScan: (() -> Void)?
  var onReserveTimeUp: (()->Void)?
  
  func setupUI() {
    scanButton.primaryRed()
    
    parkedAt.textColor = UIColor.primaryGreyColor
    range.textColor = UIColor.primaryGreyColor
    
    reserveButton.primaryRedBasic()
    
    waitToReserveAgainLabel.textColor = UIColor.primaryDarkColor
    
    closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    reserveButton.addTarget(self, action: #selector(reserveButtonTapped), for: .touchUpInside)
    scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
  }
  
  func updateContentWith(_ vehicle: Vehicle) {
    self.vehicle = vehicle
    scanButton.titleLabel?.textColor = .white
    rangeLabel.text = vehicle.remainderRange?.distanceString
    priceLabel.attributedText = generatePriceText(for: vehicle)
    batteryImageView.image = generateBatteryImage(for: vehicle)
    
    if vehicle.reserved {
      guard let reservedUntil = vehicle.reservedUntil else { return }
      
      reserveButton.setTitle(calculateTimeString(reservedUntil: reservedUntil), for: .normal)
      
      waitToReserveAgainLabel.isHidden = false
      // create timer to count down
      reserveTimer?.invalidate()
      
      reserveTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (timer) in
        self?.reserveButton.setTitle(self?.calculateTimeString(reservedUntil: reservedUntil), for: .normal)
        
        let remainingReservedTime = Int(reservedUntil.timeIntervalSinceNow)
        if remainingReservedTime > 0 {
          logger.debug("reserving vehicle for \(remainingReservedTime) seconds")
        }
        else {
          self?.reserveTimer?.invalidate()
          self?.waitToReserveAgainLabel.isHidden = true
          self?.onReserveTimeUp?()
        }
      })
    } else {
      reserveTimer?.invalidate()
    }
  }
  
  private func generateBatteryImage(for vehicle: Vehicle) -> UIImage {
    let powerPercent = vehicle.powerPercent ?? 0
    
    if 30...100 ~= powerPercent {
      return Asset.icBatteryHalfDarkGray24.image
    } else {
      return Asset.icBatteryEmptyDarkGray24.image
    }
  }
  
  private func calculateTimeString(reservedUntil: Date) -> String {
    let remainingReservedTime = Int(reservedUntil.timeIntervalSinceNow)
    
    if remainingReservedTime > 0 {
      return reservedUntil.timeIntervalSinceNow.hhmmssString
    } else {
      return "Reserved"
    }
  }
  
  @objc private func closeButtonTapped() {
    onClose?()
  }
  
  @objc private func reserveButtonTapped() {
    guard let vehicle = vehicle else { return }
    if vehicle.reserved {
      return
    }
    onReserve?(vehicle)
  }
  
  @objc private func scanButtonTapped() {
    onScan?()
  }
  
  private func generatePriceText(for vehicle: Vehicle) -> NSMutableAttributedString {
    let unlockText = NSAttributedString(string: vehicle.unlockCost.stringWithNoCurrencySign, attributes: moneyAttributes)
    let toUnLockText = NSAttributedString(string: " to unlock ", attributes: textAttributes)
    let rideCostText = NSAttributedString(string: vehicle.rideMinuteCost.stringWithNoCurrencySign, attributes: moneyAttributes)
    let perMinText = NSAttributedString(string: " per min", attributes: textAttributes)
    
    let priceText = NSMutableAttributedString()
    priceText.append(unlockText)
    priceText.append(toUnLockText)
    priceText.append(rideCostText)
    priceText.append(perMinText)
    
    return priceText
  }
  
  private lazy var moneyAttributes: [NSAttributedString.Key: Any] = {
    return [
      NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 19)
      ] as [NSAttributedString.Key: Any]
  }()
  
  private lazy var textAttributes: [NSAttributedString.Key: Any] = {
    return [
      NSAttributedString.Key.foregroundColor : UIColor.primaryGreyColor,
      NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13),
      NSAttributedString.Key.baselineOffset: 2
      ] as [NSAttributedString.Key: Any]
  }()
}
