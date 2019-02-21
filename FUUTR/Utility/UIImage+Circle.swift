//
//  UIImage+Circle.swift
//  FUUTR
//
//  Created by Chris Chen on 21/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation

extension UIImage {
  var isPortrait:  Bool    { return size.height > size.width }
  var isLandscape: Bool    { return size.width > size.height }
  var breadth:     CGFloat { return min(size.width, size.height) }
  var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
  var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
  
  var circleMasked: UIImage? {
    UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
    defer { UIGraphicsEndImageContext() }
    guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
    UIBezierPath(ovalIn: breadthRect).addClip()
    UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation).draw(in: breadthRect)
    return UIGraphicsGetImageFromCurrentImageContext()
  }
}
