//
//  RideService.swift
//  OTGRider
//
//  Created by Chris Chen on 17/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation

final class RideService {
    static func unlock(vehicleCode: String, coordinate: CLLocationCoordinate2D?, completion: @escaping (Ride?, Error?) -> Void) -> URLSessionDataTask? {
        var params: JSON = [
            "vehicleCode": vehicleCode,
            ]
        
        if let coordinate = coordinate {
            params["latitude"] = coordinate.latitude
            params["longitude"] = coordinate.longitude
        }
        
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
    
    static func finish(rideId: String,
                       coordinate: CLLocationCoordinate2D,
                       incrementalEncodedPath: String,
                       incrementalDistance: Double,
                       completion: @escaping (Ride?, Error?) -> Void) -> URLSessionDataTask? {
        let params: JSON = [
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            "incrementalEncodedPath": incrementalEncodedPath,
            "incrementalDistance": incrementalDistance
        ]
        
        return APIClient.shared.load(path: "/rides/\(rideId)/finish",
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
    
    static func update(rideId: String,
                       incrementalEncodedPath: String,
                       incrementalDistance: Double,
                       completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
        let params: JSON = [
            "incrementalEncodedPath": incrementalEncodedPath,
            "incrementalDistance": incrementalDistance
        ]
        
        return APIClient.shared.load(path: "/rides/\(rideId)",
            method: .patch,
            params: params,
            completion: { (result, error) in
                completion(error)
        })
    }
    
    static func getHistoryRides(_ completion: @escaping ([Ride]?, Error?) -> Void) -> URLSessionDataTask? {
        return APIClient.shared.load(path: "/rides/me",
                                     method: .get,
                                     params: nil,
                                     completion: { (result, error) in
                                        if let jsonArray = result as? [JSON] {
                                            completion(Ride.fromJSONArray(jsonArray), nil)
                                            return
                                        }
                                        
                                        completion(nil, error)
        })
    }
    
    static func getOngoingRide(_ completion: @escaping (Ride?, Error?) -> Void) -> URLSessionDataTask? {
        return APIClient.shared.load(path: "/rides/me/ongoing",
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
