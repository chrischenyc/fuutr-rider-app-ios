//
//  UserService.swift
//  OTGRider
//
//  Created by Chris Chen on 3/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

// MARK: - authentication
final class UserService {
    func signup(withPhoneNumber phoneNumber: String,
                countryCode: UInt64,
                verificationCode: String,
                completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
        
        let params: JSON = [
            "phoneNumber": phoneNumber,
            "countryCode": countryCode,
            "verificationCode": verificationCode
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
    
    func login(withFacebookToken token: String, completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
        let params: JSON = [
            "access_token": token
        ]
        
        return APIClient.shared.load(path: "/users/facebook/auth",
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
        guard let result = result as? JSON else { return }
        
        Defaults[.userToken] = result["token"] as? String
        Defaults[.userSignedIn] = true
    }
}

// MARK: - phone verification
extension UserService {
    func startVerification(forPhoneNumber phoneNumber: String,
                           countryCode: UInt64,
                           completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
        
        let params: JSON = [
            "phoneNumber": phoneNumber,
            "countryCode": countryCode
        ]
        
        return APIClient.shared.load(path: "/users/phone/start-verification",
                                     method: .post,
                                     params: params,
                                     completion: { (result, error) in
                                        completion(error)
        })
    }
}

// MARK: - profile
extension UserService {
    func getProfile(_ completion: @escaping (Any?, Error?) -> Void) -> URLSessionDataTask? {
        return APIClient.shared.load(path: "/users/me",
                                     method: .get,
                                     params: nil,
                                     completion: { (result, error) in
                                        completion(result, error)
        })
    }
}
