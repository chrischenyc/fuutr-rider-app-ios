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
    var vehicle: String?
    var unlockTime: Date?
    var lockTime: Date?
    var duration: TimeInterval?
    var distance: Double?
    var completed: Bool = false
    var unlockCost: Double?
    var rideMinuteCost: Double?
    var pauseMinuteCost: Double?
    var totalCost: Double?
    var encodedPath: String?
    var paused: Bool = false
    var pausedUntil: Date?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id              <- map["_id"]
        vehicle         <- map["vehicle"]
        unlockTime      <- (map["unlockTime"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
        lockTime        <- (map["lockTime"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
        duration        <- map["duration"]
        distance        <- map["distance"]
        completed       <- map["completed"]
        unlockCost      <- map["unlockCost"]
        rideMinuteCost  <- map["rideMinuteCost"]
        pauseMinuteCost <- map["pauseMinuteCost"]
        totalCost       <- map["totalCost"]
        encodedPath     <- map["encodedPath"]
        paused          <- map["paused"]
        pausedUntil     <- (map["pausedUntil"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
    }
    
    static func fromJSONArray(_ jsonArray: [JSON]) -> [Ride]? {
        return Mapper<Ride>().mapArray(JSONArray: jsonArray)
    }
    
    public static func == (lhs: Ride, rhs: Ride) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Ride {
    mutating func refresh() {
        guard !completed else { return }
        guard let unlockTime = unlockTime else { return }
        
        let duration = Date().timeIntervalSince(unlockTime)
        self.duration = duration
        
        guard let unlockCost = unlockCost, let rideMinuteCost = rideMinuteCost else { return }
        self.totalCost = unlockCost + rideMinuteCost * (duration / 60.0)
    }
    
    func summary() -> String {
        let durationString = duration != nil ? duration!.hhmmssString : "n/a"
        let costString = totalCost != nil ? totalCost!.currencyString : "n/a"
        
        return "\nRide duration: \(durationString)\nTotal cost: \(costString)"
    }
}
