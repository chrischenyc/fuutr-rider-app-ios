//
//  FTButton.swift
//  OTGRider
//
//  Created by Chris Chen on 7/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation

@IBDesignable
class FTButton: UIButton {
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
    assertionFailure("Subclass of FTButton should override commonInit method")
  }
  
}
