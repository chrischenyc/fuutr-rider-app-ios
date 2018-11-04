//
//  AuthService.swift
//  OTGRider
//
//  Created by Chris Chen on 3/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation

final class AuthService {
    
    //    @discardableResult
    func startVerification(forMobile mobile: String,
                           completion: @escaping (Error?) -> ()) -> URLSessionDataTask? {
        
        let params: JSON = ["mobile": mobile]
        
        return APIClient.shared.load(path: "/auth/phone-verification/start",
                                     method: .get,
                                     params: params,
                                     completion: { (result, error) in
                                        // TODO: parse result to figure out success or not
                                        completion(error)
        })
        
    }
    
}
