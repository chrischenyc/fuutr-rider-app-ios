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
    
    func startVerification(forPhoneNumber phoneNumber: String,
                           countryCode: UInt64,
                           completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
        
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
    
    func signup(withPhoneNumber mobile: String,
                countryCode: UInt64,
                verificationCode: String,
                completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
        
        let params: JSON = [
            "phone_number": mobile,
            "country_code": countryCode,
            "verification_code": verificationCode
        ]
        
        return APIClient.shared.load(path: "/users/phone/signup",
                                     method: .post,
                                     params: params,
                                     completion: { (result, error) in
                                        if let result = result {
                                            self.handleAuthenticationResult(result: result)
                                        }
                                        
                                        completion(error)
        })
        
    }
    
    func signup(withEmail email: String,
                password: String,
                completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
        
        let params: JSON = [
            "email": email,
            "password": password
        ]
        
        return APIClient.shared.load(path: "/users/email/signup",
                                     method: .post,
                                     params: params,
                                     completion: { (result, error) in
                                        if let result = result {
                                            self.handleAuthenticationResult(result: result)
                                        }
                                        
                                        completion(error)
        })
    }
    
    func login(withEmail email: String,
               password: String,
               completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
        
        let params: JSON = [
            "email": email,
            "password": password
        ]
        
        return APIClient.shared.load(path: "/users/email/login",
                                     method: .post,
                                     params: params,
                                     completion: { (result, error) in
                                        if let result = result {
                                            self.handleAuthenticationResult(result: result)
                                        }
                                        
                                        completion(error)
        })
    }
    
    
    private func handleAuthenticationResult(result: Any) {
        guard let result = result as? [String: Any] else { return }
        
        Defaults[.userToken] = result["token"] as? String
        Defaults[.userSignedIn] = true
    }
}
