//
//  FTDarkBasicButton.swift
//  OTGRider
//
//  Created by Chris Chen on 6/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit

@IBDesignable
class FTDarkBasicButton: FTButton {
  override func commonInit() {
    backgroundColor = .clear
    setTitleColor(UIColor.primaryDarkColor, for: .normal)
    
    alpha = isEnabled ? 1.0 : 0.5
  }
}
