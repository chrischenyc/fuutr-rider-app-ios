//
//  Vehicle.swift
//  FUUTR
//
//  Created by Chris Chen on 13/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation
import ObjectMapper

struct Vehicle: Mappable {
  var _id: String = ""
  var powerPercent: Int?
  var remainingRange: Double?
  var latitude: Double?
  var longitude: Double?
  var address: String?
  var vehicleCode: String?
  var reserved: Bool = false
  var reservedUntil: Date?
  var canReserveAfter: Date?
  var unlockCost: Double = 0
  var rideMinuteCost: Double = 0
  var pauseMinuteCost: Double = 0
  var locked: Bool = false  // vehicle may be locked if a ride is paused
  var inRide: Bool = false
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    _id             <- map["_id"]
    powerPercent    <- map["powerPercent"]
    remainingRange  <- map["remainingRange"]
    latitude        <- map["latitude"]
    longitude       <- map["longitude"]
    address         <- map["address"]
    vehicleCode     <- map["vehicleCode"]
    reserved        <- map["reserved"]
    reservedUntil   <- (map["reservedUntil"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
    canReserveAfter <- (map["canReserveAfter"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
    unlockCost      <- map["unlockCost"]
    rideMinuteCost  <- map["rideMinuteCost"]
    pauseMinuteCost <- map["pauseMinuteCost"]
    locked          <- map["locked"]
    inRide          <- map["inRide"]
  }
  
  static func fromJSONArray(_ jsonArray: [JSON]) -> [Vehicle]? {
    return Mapper<Vehicle>().mapArray(JSONArray: jsonArray)
  }
}


extension Vehicle {
  var batteryImage: UIImage? {
    let powerPercent = self.powerPercent ?? 0
    
    if 0...20 ~= powerPercent {
      return R.image.icBattery0DarkGray24()
    }
    else if 20...40 ~= powerPercent {
      return R.image.icBattery25DarkGray24()
    }
    else if 40...60 ~= powerPercent {
      return R.image.icBattery50DarkGray24()
    }
    else if 60...80 ~= powerPercent {
      return R.image.icBattery75DarkGray24()
    } else {
      return R.image.icBattery100DarkGray24()
    }
  }
}
