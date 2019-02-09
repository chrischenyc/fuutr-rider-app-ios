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
  func layoutCornerRadiusMask(corners: UIRectCorner, cornerRadius: CGFloat = CGFloat.defaultCornerRadius) {
    let cornerRadii = CGSize(width: cornerRadius, height: cornerRadius)
    let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: cornerRadii)
    
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    
    layer.mask = mask
  }
}
