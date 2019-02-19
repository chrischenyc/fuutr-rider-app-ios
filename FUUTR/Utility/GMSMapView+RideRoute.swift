//
//  GMSMapView+RideRoute.swift
//  FUUTR
//
//  Created by Chris Chen on 13/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation
import GoogleMaps

private var rideRoutePolyline: GMSPolyline?

extension GMSMapView {
  func drawRouteFor(ride: Ride) {
    clear()
    
    if let encodedPath = ride.encodedPath,
      let path = GMSPath(fromEncodedPath: encodedPath),
      path.count() > 1 {
      
      let startCoordinate = path.coordinate(at: 0)
      let startMarker = GMSMarker(position: startCoordinate)
      startMarker.icon = R.image.icLocationRed32()
      startMarker.map = self
      
      let finishCoordiante = path.coordinate(at: path.count() - 1)
      let finishMarker = GMSMarker(position: finishCoordiante)
      finishMarker.icon = R.image.icLocationFinalRed32()
      finishMarker.map = self
      
      // adjust map centre and zoom level
      var coordinates: [CLLocationCoordinate2D] = []
      var bounds = GMSCoordinateBounds()
      for index in 0..<path.count() {
        coordinates.append(path.coordinate(at: index))
        bounds = bounds.includingCoordinate(path.coordinate(at: index))
      }
      animate(with: GMSCameraUpdate.fit(bounds))
      
      // draw route
      rideRoutePolyline = GMSPolyline(path: path)
      rideRoutePolyline?.strokeWidth = 4
      rideRoutePolyline?.strokeColor = UIColor.primaryRedColor
      rideRoutePolyline?.map = self
    }
  }
}
