//
//  FTLabel.swift
//  OTGRider
//
//  Created by Chris Chen on 9/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit

class FTLabel: UILabel {
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
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    commonInit()
  }
  
  func commonInit() {
    assertionFailure("Subclass of FTLabel should override commonInit method")
  }
  
}
