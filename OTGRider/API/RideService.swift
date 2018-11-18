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
    
    static func lock(scooterId: String,
                     rideId: String,
                     coordinate: CLLocationCoordinate2D?,
                     path: GMSPath?,
                     completion: @escaping (Ride?, Error?) -> Void) -> URLSessionDataTask? {
        var params: JSON = [
            "scooterId": scooterId,
            "rideId": rideId
        ]
        
        if let coordinate = coordinate {
            params["latitude"] = coordinate.latitude
            params["longitude"] = coordinate.longitude
        }
        
        if let path = path {
            params["encodedPath"] = path.encodedPath()
            params["distance"] = path.length(of: GMSLengthKind.geodesic)
        }
        
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
}
