//
//  RemoteConfig.swift
//  FUUTR
//
//  Created by Chris Chen on 12/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation
import ObjectMapper

struct RemoteConfig: Mappable {
  var unlockCost: Double = 1
  var rideMinuteCost: Double = 0.2
  var pauseMinuteCost: Double = 0.1
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    unlockCost      <- map["unlockCost"]
    rideMinuteCost  <- map["rideMinuteCost"]
    pauseMinuteCost <- map["pauseMinuteCost"]
  }
}
