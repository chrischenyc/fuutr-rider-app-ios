@IBDesignable
class VehicleInfoView2: DesignableView {
  
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var parkedAt: UILabel!
  @IBOutlet weak var parkedLabel: UILabel!
  
  @IBOutlet weak var range: UILabel!
  @IBOutlet weak var rangeLabel: UILabel!
  
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var reserveButton: UIButton!
  @IBOutlet weak var scanButton: UIButton!
  
  override var nibName: String {
    get {
      return "VehicleInfoView"
    }
    set {}
  }
  
  func updateContentWith(_ vehicle: Vehicle) {
    scanButton.backgroundColor = UIColor.primaryRedColor
    scanButton.titleLabel?.textColor = .white
    scanButton.layer.cornerRadius = 5
    
    parkedAt.textColor = UIColor.primaryGreyColor
    range.textColor = UIColor.primaryGreyColor
    
    reserveButton.layer.borderColor = UIColor.primaryRedColor.cgColor
    reserveButton.layer.borderWidth = 2
    reserveButton.layer.cornerRadius = 5
    reserveButton.titleLabel?.textColor = UIColor.primaryRedColor
    
    rangeLabel.text = vehicle.remainderRange?.distanceString
    
    priceLabel.attributedText = generatePriceText(with: vehicle)
  }
  
  private func generatePriceText(with vehicle: Vehicle) -> NSMutableAttributedString {
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
