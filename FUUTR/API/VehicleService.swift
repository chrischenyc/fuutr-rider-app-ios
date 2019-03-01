//
//  VehicleService.swift
//  FUUTR
//
//  Created by Chris Chen on 13/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation

final class VehicleService {
  static func reserve(id: String, reserve: Bool, completion: @escaping (Vehicle?, Error?) -> Void) -> URLSessionDataTask? {
    
    let params: JSON = [
      "reserve": reserve,
      ]
    
    return APIClient.shared.load(path: "/vehicles/\(id)/reserve",
      method: .patch,
      params: params,
      completion: { (result, error) in
        
        guard error == nil else {
          completion(nil, error)
          return
        }
        
        if let json = result as? JSON, let vehicle = Vehicle(JSON: json) {
          completion(vehicle, nil)
        }
        else {
          completion(nil, NetworkError.other)
        }
    })
  }
  
  static func toot(coordinates: CLLocationCoordinate2D, id: String, completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
    
    let params: JSON = [
      "latitude": coordinates.latitude,
      "longitude": coordinates.longitude,
      ]
    
    return APIClient.shared.load(path: "/vehicles/\(id)/toot",
      method: .post,
      params: params,
      completion: { (result, error) in
        completion(error)
    })
  }
}
