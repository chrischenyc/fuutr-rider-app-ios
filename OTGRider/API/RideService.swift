//
//  RideService.swift
//  OTGRider
//
//  Created by Chris Chen on 17/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation

final class RideService {
    static func getCurrentOpenRide(_ completion: @escaping (Ride?, Error?) -> Void) -> URLSessionDataTask? {
        return APIClient.shared.load(path: "/rides/current",
                                     method: .get,
                                     params: nil,
                                     completion: { (result, error) in
                                        if let json = result as? JSON, let ride = Ride(JSON: json) {
                                            completion(ride, nil)
                                            return
                                        }
                                        
                                        completion(nil, error)
        })
    }
}
