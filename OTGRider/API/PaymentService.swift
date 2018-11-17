//
//  PaymentService.swift
//  OTGRider
//
//  Created by Chris Chen on 17/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import Stripe

final class PaymentService: NSObject {
    static func topUpBalance(_ amount: Int,
                             stripeSource: String,
                             completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
        
        let params: JSON = [
            "amount": amount,
            "source": stripeSource,
            ]
        
        return APIClient.shared.load(path: "/payments/top-up",
                                     method: .put,
                                     params: params,
                                     completion: { (result, error) in
                                        completion(error)
        })
    }
    
    static func getHistoryPayments(completion: @escaping ([Payment]?, Error?) -> Void) -> URLSessionDataTask? {
        return APIClient.shared.load(path: "/payments",
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

extension PaymentService: STPEphemeralKeyProvider {
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        _ = APIClient.shared.load(path: "/payments/stripe-ephemeral-keys",
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
