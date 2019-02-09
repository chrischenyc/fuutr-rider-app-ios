//
//  TimeInterval+hhmmss.swift
//  FUUTR
//
//  Created by Chris Chen on 16/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation

extension TimeInterval {
  var hhmmssString: String {
    guard self >= 60 else {
      return String(format: "%.0f s", self)
    }
    
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = .positional
    
    return formatter.string(from: self)!
  }
}
