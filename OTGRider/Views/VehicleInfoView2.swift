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
    
    priceLabel.text = "Unlock for \(vehicle.unlockCost.currencyString) + \(vehicle.rideMinuteCost.currencyString)/min"
  }
}
