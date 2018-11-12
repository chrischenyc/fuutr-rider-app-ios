//
//  ScooterService.swift
//  OTGRider
//
//  Created by Chris Chen on 13/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation

final class ScooterService {
    func search(latitude: Double, longitude: Double, radius: Double, completion: @escaping ([Scooter]?, Error?) -> Void) -> URLSessionDataTask? {
        
        let params: JSON = [
            "latitude": latitude,
            "longitude": longitude,
            "radius": radius
        ]
        
        return APIClient.shared.load(path: "/scooters/search",
                                     method: .get,
                                     params: params,
                                     completion: { (result, error) in
                                        if let jsonArray = result as? [JSON] {
                                            completion(Scooter.fromJSONArray(jsonArray), nil)
                                            return
                                        }
                                        
                                        completion(nil, error)
        })
    }
}
