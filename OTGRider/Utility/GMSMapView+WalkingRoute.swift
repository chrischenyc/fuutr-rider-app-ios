//
//  GMSMapView+WalkingRoute.swift
//  OTGRider
//
//  Created by Chris Chen on 31/1/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation
import GoogleMaps

private var googleMapsAPITask: URLSessionTask?
private var routePolylines: [GMSPolyline]?

extension GMSMapView {
  func drawWalkingRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
    googleMapsAPITask?.cancel()
    
    googleMapsAPITask = GoogleMapsService.getWalkingRoute(from: from, to: to, completion: {
      (route, error) in
      
      if let route = route, let steps = route.legs.first?.steps {
        self.clearWalingRoute()
        
        DispatchQueue.main.async {
          steps.forEach { step in
            guard let points = step.polyline?.points else { return }
            let path = GMSPath.init(fromEncodedPath: points)
            let polyline = GMSPolyline.init(path: path)
            polyline.strokeWidth = 4
            polyline.map = self
            
            // dotted stroke: https://stackoverflow.com/questions/24384209/ios-google-sdk-map-cannot-create-dotted-polylines
            let styles: [GMSStrokeStyle] = [.solidColor(.primaryRedColor), .solidColor(.clear)]
            let scale = 1.0 / self.projection.points(forMeters: 1, at: self.camera.target)
            let solidLine = NSNumber(value: 4.0 * Float(scale))
            let gap = NSNumber(value: 4.0 * Float(scale))
            polyline.spans = GMSStyleSpans(polyline.path!, styles, [solidLine, gap], GMSLengthKind.rhumb)
            
            routePolylines?.append(polyline)
          }
        }
      }
    })
  }
  
  func clearWalingRoute() {
    DispatchQueue.main.async {
      routePolylines?.forEach {
        $0.map = nil
      }
      
      routePolylines = []
    }
  }
}
