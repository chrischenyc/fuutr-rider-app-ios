//
//  RideService.swift
//  OTGRider
//
//  Created by Chris Chen on 17/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation

final class RideService {
    static func getOngoingRide(_ completion: @escaping (Ride?, Error?) -> Void) -> URLSessionDataTask? {
        return APIClient.shared.load(path: "/rides/ongoing",
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
    
    static func unlock(vehicleCode: String, completion: @escaping (Ride?, Error?) -> Void) -> URLSessionDataTask? {
        let params: JSON = [
            "vehicleCode": vehicleCode
        ]
        
        return APIClient.shared.load(path: "/rides/unlock",
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
    
    static func lock(scooterId: String, rideId: String, completion: @escaping (Ride?, Error?) -> Void) -> URLSessionDataTask? {
        let params: JSON = [
            "scooterId": scooterId,
            "rideId": rideId
        ]
        
        return APIClient.shared.load(path: "/rides/lock",
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
