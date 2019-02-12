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
  
  @IBAction func scanButtonTapped(_ sender: Any) {
    onScan?()
  }
  
  @IBAction func findMeButtonTapped(_ sender: Any) {
    onFindMe?()
  }
}
