@IBDesignable
class VehicleInfoView: DesignableView, InfoView {
  
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var parkedLabel: UILabel!
  @IBOutlet weak var rangeLabel: UILabel!
  @IBOutlet weak var reserveButton: UIButton!
  @IBOutlet weak var ringButton: UIButton!
  @IBOutlet weak var waitToReserveAgainLabel: UILabel!
  @IBOutlet weak var batteryImageView: UIImageView!
  @IBOutlet weak var unlockCodeLabel: UILabel!
  
  override var nibName: String {
    get {
      return "VehicleInfoView"
    }
    set {}
  }
  
  var bottomToSuperViewSpace: CGFloat {
    return 0
  }
  
  private var reserveTimer: Timer?
  private var vehicle: Vehicle?
  
  var onReserve: ((Vehicle)-> Void)?
  var onClose: (() -> Void)?
  var onScan: (() -> Void)?
  var onRing: ((Vehicle) -> Void)?
  
  func updateContentWith(_ vehicle: Vehicle) {
    self.vehicle = vehicle
    rangeLabel.text = vehicle.remainingRange?.distanceString
    priceLabel.attributedText = generatePriceText(for: vehicle)
    batteryImageView.image = vehicle.batteryImage
    unlockCodeLabel.text = vehicle.unlockCode
    
    if let address = vehicle.address {
      parkedLabel.text = address
    }
    else {
      parkedLabel.text = "--"
    }
    
    if !canReserveVehicle() {
      guard let canReserveAfter = vehicle.canReserveAfter else { return }
      
      reserveButton.setTitle(calculateTimeString(canReserveAfter: canReserveAfter), for: .disabled)
      reserveButton.isEnabled = false
      waitToReserveAgainLabel.isHidden = false
      // create timer to count down
      reserveTimer?.invalidate()
      
      reserveTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (timer) in
        self?.reserveButton.setTitle(self?.calculateTimeString(canReserveAfter: canReserveAfter), for: .disabled)
        
        let remainingReservedTime = Int(canReserveAfter.timeIntervalSinceNow)
        if remainingReservedTime <= 0 {
          self?.reserveTimer?.invalidate()
          self?.waitToReserveAgainLabel.isHidden = true
          self?.reserveButton.setTitle("Reserve", for: .normal)
          self?.reserveButton.isEnabled = true
        }
      })
    } else {
      reserveTimer?.invalidate()
      reserveButton.setTitle("Reserve", for: .normal)
      reserveButton.isEnabled = true
      reserveButton.isEnabled = true
    }
  }
  
  private func calculateTimeString(canReserveAfter: Date) -> String {
    let remainingWaitTime = Int(canReserveAfter.timeIntervalSinceNow)
    
    if remainingWaitTime > 0 {
      return canReserveAfter.timeIntervalSinceNow.hhmmssString
    } else {
      return "Reserve"
    }
  }
  
  @IBAction func closeButtonTapped() {
    onClose?()
  }
  
  @IBAction func reserveButtonTapped() {
    guard let vehicle = vehicle else { return }
    
    UISelectionFeedbackGenerator().selectionChanged()
    
    if vehicle.reserved {
      return
    }
    onReserve?(vehicle)
  }
  
  @IBAction func ringButtonTapped(_ sender: Any) {
    guard let vehicle = vehicle else { return }
    
    UISelectionFeedbackGenerator().selectionChanged()
    
    onRing?(vehicle)
  }
  
  private func canReserveVehicle() -> Bool {
    guard let vehicle = vehicle else { return false }
    if vehicle.reserved {
      return false
    }
    guard let canReserveAfter = vehicle.canReserveAfter else { return true }
    return Int(canReserveAfter.timeIntervalSinceNow) <= 0
  }
  
  @IBAction func scanButtonTapped() {
    UISelectionFeedbackGenerator().selectionChanged()
    onScan?()
  }
  
  private func generatePriceText(for vehicle: Vehicle) -> NSMutableAttributedString {
    let unlockText = NSAttributedString(string: vehicle.unlockCost.priceStringWithoutCurrency, attributes: moneyAttributes)
    let toUnLockText = NSAttributedString(string: " to unlock ", attributes: textAttributes)
    let rideCostText = NSAttributedString(string: vehicle.rideMinuteCost.priceStringWithoutCurrency, attributes: moneyAttributes)
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
      NSAttributedString.Key.foregroundColor : UIColor.primaryDarkColor,
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
