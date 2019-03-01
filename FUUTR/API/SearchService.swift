//
//  SearchService.swift
//  FUUTR
//
//  Created by Chris Chen on 25/1/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation

final class SearchService {
  static func search(coordinates: CLLocationCoordinate2D, radius: Double, completion: @escaping ([Vehicle]?, [Zone]?, Error?) -> Void) -> URLSessionDataTask? {
    
    let params: JSON = [
      "latitude": coordinates.latitude,
      "longitude": coordinates.longitude,
      "radius": radius,
      ]
    
    return APIClient.shared.load(path: "/search", method: .get, params: params, completion: { (result, error) in
      
      guard error == nil else {
        completion(nil, nil, error)
        return
      }
      
      
      if let json = result as? JSON {
        var vehiclesResult = [Vehicle]()
        var zonesResult = [Zone]()
        
        if let jsonArray = json["vehicles"] as? [JSON], let vehicles = Vehicle.fromJSONArray(jsonArray) {
          vehiclesResult = vehicles
        }
        
        if let jsonArray = json["zones"] as? [JSON], let zones = Zone.fromJSONArray(jsonArray) {
          zonesResult = zones
        }
        
        completion(vehiclesResult, zonesResult, error)
      }
      else {
        completion(nil, nil, NetworkError.other)
      }
      
    })
  }
}
