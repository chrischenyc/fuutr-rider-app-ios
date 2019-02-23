//
//  UnlockInfoView.swift
//  FUUTR
//
//  Created by Chris Chen on 15/10/18.
//  Copyright © 2019 FUUTR. All rights reserved.
//

@IBDesignable
class UnlockInfoView: DesignableView {
  
  @IBOutlet weak var priceLabel: UILabel!
  
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
  
  override func commonInit() {
    super.commonInit()
    
    let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp))
    swipeUpRecognizer.direction = .up
    addGestureRecognizer(swipeUpRecognizer)
    let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
    swipeDownRecognizer.direction = .down
    addGestureRecognizer(swipeDownRecognizer)
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
      
      onSwipeUp?()
    }
  }
  
  @objc func swipeDown() {
    if didSwipUp {
      didSwipUp = false
      
      onSwipeDown?()
    }
  }
}
