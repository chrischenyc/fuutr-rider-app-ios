@IBDesignable
class VehicleInfoView: DesignableView {
  
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var parkedLabel: UILabel!
  @IBOutlet weak var rangeLabel: UILabel!
  @IBOutlet weak var reserveButton: UIButton!
  @IBOutlet weak var waitToReserveAgainLabel: UILabel!
  @IBOutlet weak var batteryImageView: UIImageView!
  
  override var nibName: String {
    get {
      return "VehicleInfoView"
    }
    set {}
  }
  
  private var reserveTimer: Timer?
  private var vehicle: Vehicle?
  
  var onReserve: ((Vehicle)-> Void)?
  var onClose: (() -> Void)?
  var onScan: (() -> Void)?
  
  func updateContentWith(_ vehicle: Vehicle) {
    self.vehicle = vehicle
    rangeLabel.text = vehicle.remainingRange?.distanceString
    priceLabel.attributedText = generatePriceText(for: vehicle)
    batteryImageView.image = generateBatteryImage(for: vehicle)
    
    if let address = vehicle.address {
      parkedLabel.text = address
    }
    else {
      parkedLabel.text = "--"
    }
    
    if !canReserveVehicle() {
      guard let canReserveAfter = vehicle.canReserveAfter else { return }
      
      reserveButton.setTitle(calculateTimeString(canReserveAfter: canReserveAfter), for: .normal)
      reserveButton.isEnabled = false
      waitToReserveAgainLabel.isHidden = false
      // create timer to count down
      reserveTimer?.invalidate()
      
      reserveTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (timer) in
        self?.reserveButton.setTitle(self?.calculateTimeString(canReserveAfter: canReserveAfter), for: .normal)
        
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
  
  private func generateBatteryImage(for vehicle: Vehicle) -> UIImage {
    let powerPercent = vehicle.powerPercent ?? 0
    
    if 30...100 ~= powerPercent {
      return R.image.icBatteryHalfDarkGray24()!
    } else {
      return R.image.icBatteryEmptyDarkGray24()!
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
    if vehicle.reserved {
      return
    }
    onReserve?(vehicle)
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
