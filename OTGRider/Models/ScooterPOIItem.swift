//
//  ScooterPOIItem.swift
//  OTGRider
//
//  Created by Chris Chen on 13/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation

class ScooterPOIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var iotCode: String?
    var vehicleCode: String?
    var powerPercent: Int?
    var remainderRange: Int?
    
    init(scooter: Scooter) {
        self.position = CLLocationCoordinate2DMake(scooter.latitude!, scooter.longitude!)
        self.iotCode = scooter.iotCode
        self.vehicleCode = scooter.vehicleCode
        self.powerPercent = scooter.powerPercent
        self.remainderRange = scooter.remainderRange
    }
}
