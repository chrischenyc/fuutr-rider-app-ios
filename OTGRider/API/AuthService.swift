//
//  AuthService.swift
//  OTGRider
//
//  Created by Chris Chen on 3/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation

final class AuthService {
    
    func startVerification(forMobile mobile: String,
                           completion: @escaping (Error?) -> ()) -> URLSessionDataTask? {
        
        let params: JSON = ["phone_number": mobile]
        
        return APIClient.shared.load(path: "/auth/phone-verification/start",
                                     method: .get,
                                     params: params,
                                     completion: { (result, error) in
                                        completion(error)
        })
        
    }
    
    func checkVerification(forMobile mobile: String,
                           verificationCode: String,
                           completion: @escaping (Error?) -> ()) -> URLSessionDataTask? {
        
        let params: JSON = ["phone_number": mobile, "verification_code": verificationCode]
        
        return APIClient.shared.load(path: "/auth/phone-verification/check",
                                     method: .get,
                                     params: params,
                                     completion: { (result, error) in
                                        completion(error)
        })
        
    }
    
}
