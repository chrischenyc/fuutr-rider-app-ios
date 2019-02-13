//
//  GMSMapView+WalkingRoute.swift
//  FUUTR
//
//  Created by Chris Chen on 31/1/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation
import GoogleMaps

private var googleMapsAPITask: URLSessionTask?
private var walkingRoutePolyline: GMSPolyline?

extension GMSMapView {
  func drawWalkingRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
    clear()
    
    googleMapsAPITask?.cancel()
    
    googleMapsAPITask = GoogleMapsService.getWalkingRoute(from: from, to: to, completion: {
      (route, error) in
      
      if let route = route, let steps = route.legs.first?.steps {
        self.clearWalkingRoute()
        
        DispatchQueue.main.async {
          let routePath = GMSMutablePath()
          
          steps.forEach { step in
            guard let points = step.polyline?.points else { return }
            guard let path = GMSPath(fromEncodedPath: points) else { return }
            
            for index in 0..<path.count() {
              routePath.add(path.coordinate(at: index))
            }
          }
          
          walkingRoutePolyline = GMSPolyline.init(path: routePath)
          
          if let routePolyline = walkingRoutePolyline {
            
            routePolyline.strokeWidth = 4
            routePolyline.map = self
            
            // dotted stroke
            // https://stackoverflow.com/questions/24384209/ios-google-sdk-map-cannot-create-dotted-polylines
            let styles: [GMSStrokeStyle] = [.solidColor(.primaryRedColor), .solidColor(.clear)]
            let scale = 1.0 / self.projection.points(forMeters: 1, at: self.camera.target)
            let solidLine = NSNumber(value: 4.0 * Float(scale))
            let gap = NSNumber(value: 4.0 * Float(scale))
            routePolyline.spans = GMSStyleSpans(routePolyline.path!, styles, [solidLine, gap], GMSLengthKind.rhumb)
          }
        }
      }
    })
  }
  
  func clearWalkingRoute() {
    DispatchQueue.main.async {
      walkingRoutePolyline?.map = nil
      walkingRoutePolyline = nil
    }
  }
}
