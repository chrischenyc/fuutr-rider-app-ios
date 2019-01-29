//
//  UIView+CornerRadius.swift
//  OTGRider
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
    
    // Apply corner radius and rounded shadow path
    func layoutCornerRadiusAndShadow(_ cornerRadius: CGFloat = CGFloat.defaultCornerRadius) {
        // Apply corner radius for background fill only
        layer.cornerRadius = cornerRadius
        
        // Apply shadow with rounded path
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 2.0
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
    
}
