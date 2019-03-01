//
//  RideService.swift
//  FUUTR
//
//  Created by Chris Chen on 17/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation

final class RideService {
  static func start(unlockCode: String, completion: @escaping (Ride?, Error?) -> Void) -> URLSessionDataTask? {
    let params: JSON = [
      "unlockCode": unlockCode,
      ]
    
    return APIClient.shared.load(path: "/rides/start",
                                 method: .post,
                                 params: params,
                                 completion: { (result, error) in
                                  
                                  guard error == nil else {
                                    if error!.localizedDescription == "insufficient balance" {
                                      completion(nil, AppError.lowBalance)
                                      return
                                    }
                                    
                                    completion(nil, error)
                                    return
                                  }
                                  
                                  if let json = result as? JSON {
                                    completion(Ride(JSON: json), nil)
                                  }
                                  else {
                                    completion(nil, NetworkError.other)
                                  }
    })
  }
  
  static func pause(rideId: String, completion: @escaping (Ride?, Error?) -> Void) -> URLSessionDataTask? {
    return APIClient.shared.load(path: "/rides/\(rideId)/pause",
      method: .patch,
      params: nil,
      completion: { (result, error) in
        if let json = result as? JSON {
          completion(Ride(JSON: json), nil)
          return
        }
        
        completion(nil, error)
    })
  }
  
  static func resume(rideId: String, completion: @escaping (Ride?, Error?) -> Void) -> URLSessionDataTask? {
    return APIClient.shared.load(path: "/rides/\(rideId)/resume",
      method: .patch,
      params: nil,
      completion: { (result, error) in
        if let json = result as? JSON {
          completion(Ride(JSON: json), nil)
          return
        }
        
        completion(nil, error)
    })
  }
  
  static func finish(rideId: String, completion: @escaping (Ride?, Error?) -> Void) -> URLSessionDataTask? {
    return APIClient.shared.load(path: "/rides/\(rideId)/finish",
      method: .post,
      params: nil,
      completion: { (result, error) in
        if let json = result as? JSON {
          completion(Ride(JSON: json), nil)
          return
        }
        
        completion(nil, error)
    })
  }
  
  static func parkedPhoto(rideId: String, image: UIImage, completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
    return APIClient.shared.load(path: "/rides/\(rideId)/parked",
      method: .post,
      params: nil,
      image: image,
      completion: { (result, error) in
        completion(error)
    })
  }
  
  static func rate(rideId: String, rating: Int, completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
    let params: JSON = [
      "rating": rating,
      ]
    
    return APIClient.shared.load(path: "/rides/\(rideId)/rate",
      method: .post,
      params: params,
      completion: { (result, error) in
        completion(error)
    })
  }
  
  static func getHistoryRides(_ completion: @escaping ([Ride]?, Error?) -> Void) -> URLSessionDataTask? {
    return APIClient.shared.load(path: "/rides/me/history",
                                 method: .get,
                                 params: nil,
                                 completion: { (result, error) in
                                  
                                  guard error == nil else {
                                    completion(nil, error)
                                    return
                                  }
                                  
                                  if let jsonArray = result as? [JSON] {
                                    completion(Ride.fromJSONArray(jsonArray), nil)
                                  }
                                  else {
                                    completion(nil, NetworkError.other)
                                  }
    })
  }
  
  static func getOngoingRide(_ completion: @escaping (Ride?, Error?) -> Void) -> URLSessionDataTask? {
    return APIClient.shared.load(path: "/rides/me/ongoing",
                                 method: .get,
                                 params: nil,
                                 completion: { (result, error) in
                                  
                                  guard error == nil else {
                                    completion(nil, error)
                                    return
                                  }
                                  
                                  if let json = result as? JSON, let ride = Ride(JSON: json) {
                                    completion(ride, nil)
                                  }
                                  else {
                                    completion(nil, NetworkError.other)
                                  }
    })
  }
  
  static func getRide(_ _id: String, completion: @escaping (Ride?, Error?) -> Void) -> URLSessionDataTask? {
    return APIClient.shared.load(path: "/rides/\(_id)",
      method: .get,
      params: nil,
      completion: { (result, error) in
        
        guard error == nil else {
          completion(nil, error)
          return
        }
        
        if let json = result as? JSON, let ride = Ride(JSON: json) {
          completion(ride, nil)
        }
        else {
          completion(nil, NetworkError.other)
        }
    })
  }
}
