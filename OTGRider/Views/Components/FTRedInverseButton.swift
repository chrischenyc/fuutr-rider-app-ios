//
//  FTRedInverseButton.swift
//  OTGRider
//
//  Created by Chris Chen on 6/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit

@IBDesignable
class FTRedInverseButton: FTButton {
  override func commonInit() {
    backgroundColor = UIColor.clear
    layer.borderColor = UIColor.primaryRedColor.cgColor
    layer.borderWidth = 2
    layer.cornerRadius = .defaultCornerRadius
    setTitleColor(UIColor.primaryRedColor, for: .normal)
    
    alpha = isEnabled ? 1.0 : 0.5
  }
}

