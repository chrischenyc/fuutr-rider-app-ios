//
//  UIImage+Scale.swift
//  FUUTR
//
//  Created by Chris Chen on 21/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation

extension UIImage {
  func jpegDataWithSizeLimit(_ expectedSizeInMb:Int) -> Data? {
    let sizeInBytes = expectedSizeInMb * 1024 * 1024
    var needCompress = true
    var imgData: Data?
    var compressingValue: CGFloat = 1.0
    while (needCompress && compressingValue > 0.0) {
      if let data = jpegData(compressionQuality: compressingValue) {
        if data.count < sizeInBytes {
          needCompress = false
          imgData = data
        } else {
          compressingValue -= 0.05
        }
      }
    }
    
    return imgData
  }
  
}
