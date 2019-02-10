//
//  FTWhiteBasicButton.swift
//  FUUTR
//
//  Created by Chris Chen on 11/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit

@IBDesignable
class FTWhiteBasicButton: FTButton {

  override func commonInit() {
    backgroundColor = .clear
    setTitleColor(UIColor.white, for: .normal)
    
    alpha = isEnabled ? 1.0 : 0.5
  }

}
