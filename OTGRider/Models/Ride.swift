//
//  Ride.swift
//  OTGRider
//
//  Created by Chris Chen on 15/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import ObjectMapper

struct Ride: Mappable {
    var vehicleCode: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        vehicleCode     <- map["vehicleCode"]
    }
}
