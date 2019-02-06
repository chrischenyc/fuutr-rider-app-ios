//
//  FTRedPrimaryButton.swift
//  OTGRider
//
//  Created by Chris Chen on 6/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit

@IBDesignable
class FTRedPrimaryButton: UIButton {
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  override func prepareForInterfaceBuilder() {
    commonInit()
  }
  
  private func commonInit() {
    layer.cornerRadius = .defaultCornerRadius
    backgroundColor = UIColor.primaryRedColor
    setTitleColor(UIColor.white, for: .normal)
  }
}
