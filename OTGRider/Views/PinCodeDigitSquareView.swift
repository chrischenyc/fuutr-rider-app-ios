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
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    let border = CALayer()
    border.backgroundColor = UIColor.lightGray.cgColor
    border.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
    self.layer.addSublayer(border)
  }
}
