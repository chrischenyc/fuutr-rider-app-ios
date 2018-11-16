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
    var minuteCost: Double?
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
        minuteCost      <- map["minuteCost"]
        rideCost        <- map["rideCost"]
        totalCost       <- map["totalCost"]
    }
    
    public static func == (lhs: Ride, rhs: Ride) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Ride {
    mutating func update(withElapsedTime time: TimeInterval) {
        guard let completed = completed, !completed else { return }
        
        guard let duration = duration else { return }
        let newDuration = duration + time
        self.duration = newDuration
        
        guard let unlockCost = unlockCost, let minuteCost = minuteCost else { return }
        self.totalCost = unlockCost + minuteCost * (newDuration / 60.0)
    }
}
