//
//  Vehicle.swift
//  OTGRider
//
//  Created by Chris Chen on 13/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import ObjectMapper

struct Vehicle: Mappable {
    var _id: String?
    var powerPercent: Int?
    var remainderRange: Int?
    var latitude: Double?
    var longitude: Double?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        _id              <- map["_id"]
        powerPercent    <- map["powerPercent"]
        remainderRange  <- map["remainderRange"]
        latitude        <- map["latitude"]
        longitude       <- map["longitude"]
    }
    
    static func fromJSONArray(_ jsonArray: [JSON]) -> [Vehicle]? {
        return Mapper<Vehicle>().mapArray(JSONArray: jsonArray)
    }
}