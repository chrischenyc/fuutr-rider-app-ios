//
//  AuthService.swift
//  OTGRider
//
//  Created by Chris Chen on 8/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

final class AuthService {
    func signup(withPhoneNumber phoneNumber: String,
                countryCode: UInt64,
                verificationCode: String,
                completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
        
        let params: JSON = [
            "phoneNumber": phoneNumber,
            "countryCode": countryCode,
            "verificationCode": verificationCode
        ]
        
        return APIClient.shared.load(path: "/auth/phone",
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
        
        return APIClient.shared.load(path: "/auth/email-signup",
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
        
        return APIClient.shared.load(path: "/auth/email-login",
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
        
        return APIClient.shared.load(path: "/auth/facebook",
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
        
        Defaults[.accessToken] = result["accessToken"] as? String
        // TODO: jwt token refresh https://trello.com/c/JAThwebl/102-jwt-token-refresh
        // Defaults[.refreshToken] = result["refreshToken"] as? String
        Defaults[.userSignedIn] = true
    }
}
