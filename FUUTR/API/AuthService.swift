//
//  AuthService.swift
//  FUUTR
//
//  Created by Chris Chen on 8/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import FBSDKLoginKit

final class AuthService {
  static func signIn(withPhoneNumber phoneNumber: String,
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
  
  static func verify(email: String,
                     completion: @escaping (String?, Error?) -> Void) -> URLSessionDataTask? {
    
    let params: JSON = [
      "email": email,
      ]
    
    return APIClient.shared.load(path: "/auth/email-verify",
                                 method: .post,
                                 params: params,
                                 completion: { (result, error) in
                                  
                                  guard error == nil,
                                    let result = result as? JSON,
                                    let displayName = result["displayName"] as? String? else {
                                      completion(nil, error)
                                      return
                                  }
                                  
                                  completion(displayName, nil)
    })
  }
  
  static func signup(withEmail email: String,
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
  
  static func login(withEmail email: String,
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
  
  static func login(withFacebookToken token: String, completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
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
  
  static func logout(_ completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
    guard let refreshToken = Defaults[.refreshToken] else { return nil }
    
    cleanUpUserState()
    
    let params: JSON = ["refreshToken": refreshToken]
    
    return APIClient.shared.load(path: "/auth/logout",
                                 method: .post,
                                 params: params,
                                 completion: { (result, error) in
                                  completion(error)
    })
  }
  
  static func refreshAccessToken(retryPath: String,
                                 retryMethod: RequestMethod,
                                 retryParams: JSON?,
                                 retryCompletion: @escaping (Any?, Error?) -> Void ) {
    
    guard let refreshToken = Defaults[.refreshToken] else {
      cleanUpUserState()
      return
    }
    
    let params: JSON = ["refreshToken": refreshToken]
    
    _ = APIClient.shared.load(path: "/auth/token",
                              method: .post,
                              params: params) { (result, error) in
                                if let result = result as? JSON,
                                  let accessToken = result["accessToken"] as? String {
                                  Defaults[.accessToken] = accessToken
                                  
                                  _ = APIClient.shared.load(path: retryPath, method: retryMethod, params: retryParams, completion: retryCompletion)
                                }
                                else {
                                  // couldn't refresh access token, force log out
                                  AuthService.cleanUpUserState()
                                }
    }
  }
  
  static func requestPasswordResetCode(forEmail email: String,
                                       completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
    
    let params: JSON = [
      "email": email
    ]
    
    return APIClient.shared.load(path: "/auth/reset-password-send-code",
                                 method: .get,
                                 params: params,
                                 completion: { (result, error) in
                                  completion(error)
    })
  }
  
  static func verifyPasswordResetCode(forEmail email: String,
                                      code: String,
                                      completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
    
    let params: JSON = [
      "email": email,
      "code": code
    ]
    
    return APIClient.shared.load(path: "/auth/reset-password-verify-code",
                                 method: .post,
                                 params: params,
                                 completion: { (result, error) in
                                  completion(error)
    })
  }
  
  static func resetPassword(forEmail email: String,
                            code: String,
                            password: String,
                            completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
    
    let params: JSON = [
      "email": email,
      "code": code,
      "password": password
    ]
    
    return APIClient.shared.load(path: "/auth/reset-password",
                                 method: .post,
                                 params: params,
                                 completion: { (result, error) in
                                  completion(error)
    })
  }
  
  static func updatePassword(currentPassword: String?,
                            newPassword: String,
                            completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
    
    var params: JSON = [
      "newPassword": newPassword
    ]
    
    if let currentPassword = currentPassword {
      params["currentPassword"] = currentPassword
    }
    
    return APIClient.shared.load(path: "/auth/update-password",
                                 method: .post,
                                 params: params,
                                 completion: { (result, error) in
                                  completion(error)
    })
  }
  
  static func requestUpdateEmailCode(to email: String,
                                     completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
    
    let params: JSON = [
      "email": email
    ]
    
    return APIClient.shared.load(path: "/auth/update-email",
                                 method: .get,
                                 params: params,
                                 completion: { (result, error) in
                                  completion(error)
    })
  }
  
  static func updateEmail(to email: String,
                          code: String,
                          completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
    
    let params: JSON = [
      "email": email,
      "code": code
    ]
    
    return APIClient.shared.load(path: "/auth/update-email",
                                 method: .post,
                                 params: params,
                                 completion: { (result, error) in
                                  completion(error)
    })
  }
}

// MARK: - helper
extension AuthService {
  private static func cleanUpUserState() {
    currentUser = nil
    currentLocation = nil
    
    Defaults[.userSignedIn] = false
    Defaults[.accessToken] = ""
    Defaults[.refreshToken] = ""
    
    DispatchQueue.main.async {
      if FBSDKAccessToken.current() != nil {
        FBSDKLoginManager().logOut()
      }
    }
  }
  
  private static func handleAuthenticationResult(result: Any) {
    guard let result = result as? JSON else { return }
    
    Defaults[.accessToken] = result["accessToken"] as? String
    Defaults[.refreshToken] = result["refreshToken"] as? String
    Defaults[.userSignedIn] = true
    
    // reset current location so the map will be re-centred once user brings back the app
    currentLocation = nil
  }
}
