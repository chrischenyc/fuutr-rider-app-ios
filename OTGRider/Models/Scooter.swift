//
//  Scooter.swift
//  OTGRider
//
//  Created by Chris Chen on 13/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import ObjectMapper

struct Scooter: Mappable {
    var iotCode: String?
    var vehicleCode: String?
    var powerPercent: Int?
    var remainderRange: Int?
    var latitude: Double?
    var longitude: Double?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        iotCode         <- map["iotCode"]
        vehicleCode     <- map["vehicleCode"]
        powerPercent    <- map["powerPercent"]
        remainderRange  <- map["remainderRange"]
        latitude        <- map["latitude"]
        longitude       <- map["longitude"]
    }
    
    static func fromJSONArray(_ jsonArray: [JSON]) -> [Scooter]? {
        return Mapper<Scooter>().mapArray(JSONArray: jsonArray)
    }
}
