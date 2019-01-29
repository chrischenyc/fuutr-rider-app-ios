import UIKit
import PinCodeView

public class PinCodeDigitSquareView: UILabel, PinCodeDigitView {
  
  public var state: PinCodeDigitViewState! = .empty {
    didSet {
      if state != oldValue {
        configure(withState: state)
      }
    }
  }
  
  public var digit: String? {
    didSet {
      guard digit != oldValue else { return }
      self.state = digit != nil ? .hasDigit : .empty
      self.text = digit
    }
  }
  
  convenience required public init() {
    self.init(frame: .zero)
    
    self.textAlignment = .center
    self.font = UIFont.systemFont(ofSize: 30)
    self.layer.borderWidth = 2
    self.layer.cornerRadius = 3
    self.textColor = UIColor.primaryDarkColor
    self.configure(withState: .empty)
    
    translatesAutoresizingMaskIntoConstraints = false
    widthAnchor.constraint(equalToConstant: 47).isActive = true
  }
  
  public func configure(withState state: PinCodeDigitViewState) {
    switch state {
    case .empty:
      layer.borderColor = UIColor.primaryGreyColor.cgColor
      
    case .hasDigit:
      layer.borderColor = UIColor.primaryDarkColor.cgColor
      
    case .failedVerification:
      layer.borderColor = UIColor.primaryRedColor.cgColor
    }
  }
}
