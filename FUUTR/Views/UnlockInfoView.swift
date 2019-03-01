//
//  UnlockInfoView.swift
//  FUUTR
//
//  Created by Chris Chen on 15/10/18.
//  Copyright © 2019 FUUTR. All rights reserved.
//

@IBDesignable
class UnlockInfoView: DesignableView, InfoView {
  
  @IBOutlet weak var pricingLabelsTopContraint: NSLayoutConstraint!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var scooterImageView: UIImageView!
  
  override var nibName: String {
    get {
      return "UnlockInfoView"
    }
    set {}
  }
  
  var onFindMe: (() -> Void)?
  var onScan: (() -> Void)?
  var onSwipeUp: (() -> Void)?
  var onSwipeDown: (() -> Void)?
  var didSwipUp = true
  var bottomToSuperViewSpace: CGFloat {
    return didSwipUp ? 0 : 140
  }
  
  override func commonInit() {
    super.commonInit()
    
    let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp))
    swipeUpRecognizer.direction = .up
    addGestureRecognizer(swipeUpRecognizer)
    let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
    swipeDownRecognizer.direction = .down
    addGestureRecognizer(swipeDownRecognizer)
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
    addGestureRecognizer(tapRecognizer)
  }
  
  @IBAction func scanButtonTapped(_ sender: Any) {
    onScan?()
  }
  
  @IBAction func findMeButtonTapped(_ sender: Any) {
    onFindMe?()
  }
  
  @objc func swipeUp() {
    if !didSwipUp {
      didSwipUp = true
      
      pricingLabelsTopContraint.constant = 32
      UIView.animate(withDuration: 0.25) {
        self.scooterImageView.alpha = 1
        self.layoutIfNeeded()
      }
      
      onSwipeUp?()
    }
  }
  
  @objc func swipeDown() {
    if didSwipUp {
      didSwipUp = false
      
      pricingLabelsTopContraint.constant = 8
      UIView.animate(withDuration: 0.25) {
        self.scooterImageView.alpha = 0
        self.layoutIfNeeded()
      }
      
      onSwipeDown?()
    }
  }
  
  @objc func tap() {
    if didSwipUp {
      swipeDown()
    } else {
      swipeUp()
    }
  }
}
