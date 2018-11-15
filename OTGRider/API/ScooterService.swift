//
//  ScooterService.swift
//  OTGRider
//
//  Created by Chris Chen on 13/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation

final class ScooterService {
    func searchInBound(minLatitude: Double, minLongitude: Double, maxLatitude: Double, maxLongitude: Double, completion: @escaping ([Scooter]?, Error?) -> Void) -> URLSessionDataTask? {
        
        let params: JSON = [
            "minLatitude": minLatitude,
            "minLongitude": minLongitude,
            "maxLatitude": maxLatitude,
            "maxLongitude": maxLongitude,
            ]
        
        return APIClient.shared.load(path: "/scooters/search-in-bound",
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
    
    func unlock(vehicleCode: String, completion: @escaping (Ride?, Error?) -> Void) -> URLSessionDataTask? {
        let params: JSON = [
            "vehicleCode": vehicleCode
        ]
        
        return APIClient.shared.load(path: "/scooters/unlock",
                                     method: .post,
                                     params: params,
                                     completion: { (result, error) in
                                        if let json = result as? JSON {
                                            completion(Ride(JSON: json), nil)
                                            return
                                        }
                                        
                                        completion(nil, error)
        })
    }
}
