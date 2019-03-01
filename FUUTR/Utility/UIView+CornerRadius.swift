//
//  UIView+CornerRadius.swift
//  FUUTR
//
//  Created by Chris Chen on 14/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation

extension UIView {
  
  // Apply clipping mask on certain corners with corner radius
  func layoutCornerRadiusMask(corners: CACornerMask, cornerRadius: CGFloat = defaultCornerRadius) {
    layer.cornerRadius = CGFloat(cornerRadius)
    clipsToBounds = true
    layer.maskedCorners = corners
  }
  
  func layoutCircularMask() {
    layoutCornerRadiusMask(corners: [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], cornerRadius: frame.size.width/2)
  }
}
