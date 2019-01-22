//
//  RideSegment.swift
//  OTGRider
//
//  Created by Chris Chen on 22/1/19.
//  Copyright © 2019 OTGRide. All rights reserved.
//

import Foundation
import ObjectMapper

struct RideSegment: Mappable, Equatable {
    var start: Date?
    var end: Date?
    var paused: Bool = false
    var cost: Double?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        start       <- (map["start"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
        end         <- (map["end"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
        paused      <- map["paused"]
        cost        <- map["cost"]
    }
    
    static func fromJSONArray(_ jsonArray: [JSON]) -> [Ride]? {
        return Mapper<Ride>().mapArray(JSONArray: jsonArray)
    }
    
}
