//
//  FTWhitePrimaryButton.swift
//  FUUTR
//
//  Created by Chris Chen on 11/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit

class FTWhitePrimaryButton: FTButton {
  override func commonInit() {
    layer.cornerRadius = defaultCornerRadius
    backgroundColor = UIColor.white
    setTitleColor(UIColor.primaryRedColor, for: .normal)
    
    alpha = isEnabled ? 1.0 : 0.5
  }
}
