//
//  VehicleService.swift
//  OTGRider
//
//  Created by Chris Chen on 13/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation

final class VehicleService {
    static func search(latitude: Double, longitude: Double, radius: Double, completion: @escaping ([Vehicle]?, Error?) -> Void) -> URLSessionDataTask? {
        
        let params: JSON = [
            "latitude": latitude,
            "longitude": longitude,
            "radius": radius,
            ]
        
        return APIClient.shared.load(path: "/vehicles",
                                     method: .get,
                                     params: params,
                                     completion: { (result, error) in
                                        if let jsonArray = result as? [JSON] {
                                            completion(Vehicle.fromJSONArray(jsonArray), nil)
                                            return
                                        }
                                        
                                        completion(nil, error)
        })
    }
    
    static func reserve(_id: String, reserve: Bool, completion: @escaping (Vehicle?, Error?) -> Void) -> URLSessionDataTask? {
        
        let params: JSON = [
            "reserve": reserve,
            ]
        
        return APIClient.shared.load(path: "/vehicles/\(_id)/reserve",
                                     method: .patch,
                                     params: params,
                                     completion: { (result, error) in
                                        if let json = result as? JSON, let vehicle = Vehicle(JSON: json) {
                                            completion(vehicle, nil)
                                            return
                                        }
                                        
                                        completion(nil, error)
        })
    }
}
