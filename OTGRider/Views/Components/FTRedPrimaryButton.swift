//
//  FTRedPrimaryButton.swift
//  FUUTR
//
//  Created by Chris Chen on 6/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit

@IBDesignable
class FTRedPrimaryButton: FTButton {
  override func commonInit() {
    layer.cornerRadius = .defaultCornerRadius
    backgroundColor = UIColor.primaryRedColor
    setTitleColor(UIColor.white, for: .normal)
    
    alpha = isEnabled ? 1.0 : 0.5
  }
  
}
