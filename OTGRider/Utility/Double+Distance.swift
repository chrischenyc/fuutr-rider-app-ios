//
//  Double+Distance.swift
//  OTGRider
//
//  Created by Chris Chen on 18/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation

extension Double {
    var distanceString: String {
        if self < 1000 {
            return String(format: "%.0f m", self)
        } else {
            return String(format: "%.2f km", self/1000.0)
        }
    }
}
