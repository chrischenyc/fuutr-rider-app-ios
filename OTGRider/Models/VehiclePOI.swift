//
//  VehiclePOI.swift
//  OTGRider
//
//  Created by Chris Chen on 13/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation

class VehiclePOI: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var vehicle: Vehicle
    
    init(vehicle: Vehicle) {
        self.position = CLLocationCoordinate2DMake(vehicle.latitude!, vehicle.longitude!)
        self.vehicle = vehicle
    }
}
