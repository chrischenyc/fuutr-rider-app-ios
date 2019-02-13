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
      startMarker.icon = GMSMarker.markerImage(with: UIColor.primaryRedColor)
      startMarker.map = self
      
      let endCoordiante = path.coordinate(at: path.count() - 1)
      let endMarker = GMSMarker(position: endCoordiante)
      endMarker.icon = GMSMarker.markerImage(with: UIColor.primaryRedColor)
      endMarker.map = self
      
      // centre map
      var coordinates: [CLLocationCoordinate2D] = []
      for index in 0..<path.count() {
        coordinates.append(path.coordinate(at: index))
      }
      let centerCoordinate = CLLocationCoordinate2D.middlePointOfListMarkers(listCoords: coordinates)
      let camera = GMSCameraPosition.camera(withTarget: centerCoordinate, zoom: streetZoomLevel)
      animate(to: camera)
      
      // draw route
      rideRoutePolyline = GMSPolyline(path: path)
      rideRoutePolyline?.strokeWidth = 4
      rideRoutePolyline?.strokeColor = UIColor.primaryRedColor
      rideRoutePolyline?.map = self
    }
  }
}
