//
//  PhoneService.swift
//  OTGRider
//
//  Created by Chris Chen on 8/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

final class PhoneService {
    static func startVerification(forPhoneNumber phoneNumber: String,
                           countryCode: UInt64,
                           completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
        
        let params: JSON = [
            "phoneNumber": phoneNumber,
            "countryCode": countryCode
        ]
        
        return APIClient.shared.load(path: "/phones/start-verification",
                                     method: .post,
                                     params: params,
                                     completion: { (result, error) in
                                        completion(error)
        })
    }
}
