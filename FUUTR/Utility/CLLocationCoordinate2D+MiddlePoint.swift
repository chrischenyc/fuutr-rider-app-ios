//
//  CLLocationCoordinate2D+MiddlePoint.swift
//  FUUTR
//
//  Created by Chris Chen on 13/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation

func degreeToRadian(angle:CLLocationDegrees) -> CGFloat {
  return (  (CGFloat(angle)) / 180.0 * .pi  )
}

//        /** Radians to Degrees **/
func radianToDegree(radian:CGFloat) -> CLLocationDegrees {
  return CLLocationDegrees(  radian * 180.0 / .pi  )
}

extension CLLocationCoordinate2D {
  static func middlePointOfListMarkers(listCoords: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
    
    var x = 0.0 as CGFloat
    var y = 0.0 as CGFloat
    var z = 0.0 as CGFloat
    
    for coordinate in listCoords{
      let lat:CGFloat = degreeToRadian(angle: coordinate.latitude)
      let lon:CGFloat = degreeToRadian(angle: coordinate.longitude)
      x = x + cos(lat) * cos(lon)
      y = y + cos(lat) * sin(lon)
      z = z + sin(lat)
    }
    
    x = x/CGFloat(listCoords.count)
    y = y/CGFloat(listCoords.count)
    z = z/CGFloat(listCoords.count)
    
    let resultLon: CGFloat = atan2(y, x)
    let resultHyp: CGFloat = sqrt(x*x+y*y)
    let resultLat:CGFloat = atan2(z, resultHyp)
    
    let newLat = radianToDegree(radian: resultLat)
    let newLon = radianToDegree(radian: resultLon)
    let result:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
    
    return result
    
  }
}
