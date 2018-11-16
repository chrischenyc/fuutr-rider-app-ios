//
//  Ride.swift
//  OTGRider
//
//  Created by Chris Chen on 15/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import ObjectMapper

struct Ride: Mappable, Equatable {
    var id: String?
    var vehicleCode: String?
    var unlockTime: Date?
    var lockTime: Date?
    var duration: TimeInterval?
    var distance: Int?
    var completed: Bool?
    var unlockCost: Double?
    var rideCost: Double?
    var totalCost: Double?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id              <- map["_id"]
        vehicleCode     <- map["vehicleCode"]
        unlockTime      <- (map["unlockTime"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
        lockTime        <- (map["lockTime"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
        duration        <- map["duration"]
        distance        <- map["distance"]
        completed       <- map["completed"]
        unlockCost      <- map["unlockCost"]
        rideCost        <- map["rideCost"]
        totalCost       <- map["totalCost"]
    }
    
    public static func == (lhs: Ride, rhs: Ride) -> Bool {
        return lhs.id == rhs.id
    }
}
