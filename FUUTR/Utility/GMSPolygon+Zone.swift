//
//  GMSPolygon+Zone.swift
//  FUUTR
//
//  Created by Chris Chen on 31/1/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation
import GoogleMaps

extension GMSPolygon {
  convenience init(zone: Zone) {
    let path = GMSMutablePath()
    
    for coordinates in zone.polygon {
      path.add(CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0]))
    }
    
    // Create the polygon, and assign it to the map.
    var fillColor: UIColor = .clear
    var strokeColor: UIColor = .clear
    
    if !zone.riding {
      fillColor = UIColor.noRidingZoneFillColor
      strokeColor = UIColor.noRidingZoneFillColor
    }
    else if !zone.parking {
      fillColor = UIColor.noParkingZoneFillColor
      strokeColor = UIColor.noParkingZoneStrokeColor
    }
    else if zone.speedMode == 1 {
      fillColor = UIColor.lowSpeedZoneFillColor
      strokeColor = UIColor.lowSpeedZoneStrokeColor
    }
    else if zone.speedMode == 2 {
      fillColor = UIColor.midSpeedZoneFillColor
      strokeColor = UIColor.midSpeedZoneStrokeColor
    }
    
    self.init(path: path)
    
    self.fillColor = fillColor
    self.strokeColor = strokeColor
    self.strokeWidth = 1
    self.geodesic = true
  }
}
