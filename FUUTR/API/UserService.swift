//
//  UserService.swift
//  FUUTR
//
//  Created by Chris Chen on 3/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

final class UserService {
  static func getProfile(_ completion: @escaping (User?, Error?) -> Void) -> URLSessionDataTask? {
    return APIClient.shared.load(path: "/users/me",
                                 method: .get,
                                 params: nil,
                                 completion: { (result, error) in
                                  if let json = result as? JSON, let user = User(JSON: json) {
                                    completion(user, nil)
                                    currentUser = user
                                    return
                                  }
                                  
                                  completion(nil, error)
    })
  }
  
  static func updateProfile(_ profile: JSON, avatar: UIImage?, completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
    return APIClient.shared.load(path: "/users/me",
                                 method: .post,
                                 params: profile,
                                 image: avatar,
                                 completion: { (result, error) in
                                  completion(error)
    })
  }
  
  static func updateEmail(_ email: String, completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
    return APIClient.shared.load(path: "/users/me/email",
                                 method: .put,
                                 params: ["email": email],
                                 completion: { (result, error) in
                                  completion(error)
    })
  }
  
  static func udpatePhoneNumber(_ phoneNumber: String,
                                countryCode: UInt64,
                                verificationCode: String,
                                completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
    
    let params: JSON = [
      "phoneNumber": phoneNumber,
      "countryCode": countryCode,
      "verificationCode": verificationCode
    ]
    
    return APIClient.shared.load(path: "/users/me/phone",
                                 method: .put,
                                 params: params,
                                 completion: { (result, error) in
                                  completion(error)
    })
  }
}

