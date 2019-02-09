//
//  GoogleMapsService.swift
//  FUUTR
//
//  Created by Chris Chen on 31/1/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation

let googleMapsClient = APIClient(baseURL: "https://maps.googleapis.com")

final class GoogleMapsService {
  static func getWalkingRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion: @escaping (Route?, Error?) -> Void) -> URLSessionDataTask? {
    
    let origin = "\(from.latitude),\(from.longitude)"
    let destination = "\(to.latitude),\(to.longitude)"
    
    let params: JSON = [
      "origin": origin,
      "destination": destination,
      "mode": "walking",
      "key": config.env.googleMapKey
    ]
    
    return googleMapsClient.load(path: "/maps/api/directions/json", method: .get, params: params, completion: { (result, error) in
      guard error == nil else {
        completion(nil, error)
        return
      }
      
      if let json = result as? JSON,
        let jsonArray = json["routes"] as? [JSON],
        let routes = Route.fromJSONArray(jsonArray) {
        completion(routes.first, nil)
      }
    })
  }
}
