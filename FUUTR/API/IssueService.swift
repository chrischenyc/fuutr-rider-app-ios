//
//  IssueService.swift
//  FUUTR
//
//  Created by Chris Chen on 17/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation

final class IssueService {
  static func createIssue(type: IssueType,
                          description: String,
                          coordinates: CLLocationCoordinate2D,
                          vehicle: Vehicle? = nil,
                          ride: Ride? = nil,
                          image: UIImage? = nil,
                          completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
    
    var params: JSON = [
      "type": type.rawValue,
      "description": description,
      "latitude": coordinates.latitude,
      "longitude": coordinates.longitude,
      ]
    
    if let vehicleId = vehicle?.id {
      params["vehicle"] = vehicleId
    }
    
    if let rideId = ride?.id {
      params["ride"] = rideId
    }
    
    return APIClient.shared.load(path: "/issues", method: .post, params: params, image: image, completion: { (result, error) in
      completion(error)
      
    })
  }
}
