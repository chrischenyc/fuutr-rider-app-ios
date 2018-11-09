//
//  UserService.swift
//  OTGRider
//
//  Created by Chris Chen on 3/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

final class UserService {
    func getProfile(_ completion: @escaping (Any?, Error?) -> Void) -> URLSessionDataTask? {
        return APIClient.shared.load(path: "/users/me",
                                     method: .get,
                                     params: nil,
                                     completion: { (result, error) in
                                        completion(result, error)
        })
    }
    
    func updateProfile(_ profile: JSON, completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
        return APIClient.shared.load(path: "/users/me",
                                     method: .patch,
                                     params: profile,
                                     completion: { (result, error) in
                                        completion(error)
        })
    }
}
