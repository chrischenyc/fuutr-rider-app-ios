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
  var duration: TimeInterval = 0
  var distance: Double = 0
  var completed: Bool = false
  var unlockCost: Double = 0
  var rideMinuteCost: Double = 0
  var pauseMinuteCost: Double = 0
  var totalCost: Double = 0
  var encodedPath: String?
  var paused: Bool = false
  var pausedUntil: Date?
  var segments: [RideSegment]?
  var initialRemainderRange: Double?  // initial range when vehicle is unlocked
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    id                    <- map["_id"]
    vehicle               <- map["vehicle"]
    unlockTime            <- (map["unlockTime"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
    lockTime              <- (map["lockTime"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
    duration              <- map["duration"]
    distance              <- map["distance"]
    completed             <- map["completed"]
    unlockCost            <- map["unlockCost"]
    rideMinuteCost        <- map["rideMinuteCost"]
    pauseMinuteCost       <- map["pauseMinuteCost"]
    totalCost             <- map["totalCost"]
    encodedPath           <- map["encodedPath"]
    paused                <- map["paused"]
    pausedUntil           <- (map["pausedUntil"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
    segments              <- map["segments"]
    initialRemainderRange <- map["initialRemainderRange"]
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
    
    self.totalCost = unlockCost
    
    if let segments = segments {
      segments.forEach { (segment) in
        if let cost = segment.cost {
          self.totalCost += cost
        }
        else if let start = segment.start {
          let segmentDuration = Date().timeIntervalSince(start)
          if segment.paused {
            self.totalCost += pauseMinuteCost * segmentDuration / 60
          }
          else {
            self.totalCost += rideMinuteCost * segmentDuration / 60
          }
        }
      }
    }
  }
  
  func summary() -> String {
    return "\nRide duration: \(duration.hhmmssString)\nTotal cost: \(totalCost.currencyString)"
  }
}
