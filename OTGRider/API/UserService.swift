//
//  UserService.swift
//  OTGRider
//
//  Created by Chris Chen on 3/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import Stripe

final class UserService: NSObject {
    func getProfile(_ completion: @escaping (User?, Error?) -> Void) -> URLSessionDataTask? {
        return APIClient.shared.load(path: "/users/me",
                                     method: .get,
                                     params: nil,
                                     completion: { (result, error) in
                                        if let json = result as? JSON, let user = User(JSON: json) {
                                            completion(user, nil)
                                            return
                                        }
                                        
                                        completion(nil, error)  
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
    
    func updateEmail(_ email: String, completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
        return APIClient.shared.load(path: "/users/me/email",
                                     method: .put,
                                     params: ["email": email],
                                     completion: { (result, error) in
                                        completion(error)
        })
    }
    
    func udpatePhoneNumber(_ phoneNumber: String,
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
    
    func topUpBalance(_ amount: Int,
                      stripeSource: String,
                      completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
        
        let params: JSON = [
            "amount": amount,
            "source": stripeSource,
            ]
        
        return APIClient.shared.load(path: "/users/me/balance",
                                     method: .put,
                                     params: params,
                                     completion: { (result, error) in
                                        completion(error)
        })
    }
    
    func getHistoryPayments(completion: @escaping ([Payment]?, Error?) -> Void) -> URLSessionDataTask? {
        return APIClient.shared.load(path: "/users/me/payments",
                                     method: .get,
                                     params: nil,
                                     completion: { (result, error) in
                                        if let jsonArray = result as? [JSON] {
                                            completion(Payment.fromJSONArray(jsonArray), nil)
                                            return
                                        }
                                        
                                        completion(nil, error)
        })
    }
}

extension UserService: STPEphemeralKeyProvider {
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        _ = APIClient.shared.load(path: "/users/me/stripe-ephemeral-keys",
                                  method: .post,
                                  params: ["stripe_version": apiVersion]) { (result, error) in
                                    guard let json = result as? [AnyHashable: Any] else {
                                        completion(nil, error)
                                        return
                                    }
                                    
                                    completion(json, nil)
        }
    }
}
