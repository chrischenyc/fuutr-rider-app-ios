//
//  UserService.swift
//  OTGRider
//
//  Created by Chris Chen on 3/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation

final class UserService {
    
    func startVerification(forPhoneNumber phoneNumber: String,
                           countryCode: Int,
                           completion: @escaping (Error?) -> ()) -> URLSessionDataTask? {
        
        let params: JSON = [
            "phone_number": phoneNumber,
            "country_code": countryCode
        ]
        
        return APIClient.shared.load(path: "/users/phone/start-verification",
                                     method: .post,
                                     params: params,
                                     completion: { (result, error) in
                                        completion(error)
        })
        
    }
    
    func signup(forPhoneNumber mobile: String,
                countryCode: Int,
                verificationCode: String,
                completion: @escaping (Error?) -> ()) -> URLSessionDataTask? {
        
        let params: JSON = [
            "phone_number": mobile,
            "country_code": countryCode,
            "verification_code": verificationCode
        ]
        
        return APIClient.shared.load(path: "/users/phone/signup",
                                     method: .post,
                                     params: params,
                                     completion: { (result, error) in
                                        completion(error)
        })
        
    }
    
}
