//
//  Double+Currency.swift
//  FUUTR
//
//  Created by Chris Chen on 9/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation

extension Double {
  var priceString: String {
    return String(format: "$%.2f", self)
  }
  
  var priceStringWithoutDecimal: String {
    return String(format: "$%.f", self)
  }
  
  var priceStringWithoutCurrency: String {
    return String(format: "%.2f", self)
  }
}
