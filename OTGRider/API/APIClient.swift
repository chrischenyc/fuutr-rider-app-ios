//
//  APIClient.swift
//  OTGRider
//
//  Created by Chris Chen on 2/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import Reachability
import SwiftyUserDefaults

enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

final class APIClient {
    static let shared: APIClient = {
        let client = APIClient(baseURL: configuration.environment.baseURL)
        
        // Configuration
        // ...
        
        return client
    }()
    
    private let baseURL: String
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    func load(path: String,
              method: RequestMethod,
              params: JSON?,
              completion: @escaping (Any?, Error?) -> Void) -> URLSessionDataTask? {
        
        // Checking internet connection availability
        guard let reachablity = Reachability(hostname: baseURL), reachablity.connection != .none else {
            log.warning(ServiceError.noInternetConnection)
            completion(nil, ServiceError.noInternetConnection)
            return nil
        }
        
        
        // Creating the URLRequest object
        let request = URLRequest(baseUrl: baseURL, path: path, method: method, params: params)
        log.debug("\(method) \(request.url?.absoluteString ?? "INVALID URL")")
        
        // Sending request to the server.
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                log.error(error!.localizedDescription)
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                log.error("missing payload")
                completion(nil, ServiceError.other)
                return
            }
            
            // Parsing incoming data
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let response = response as? HTTPURLResponse {
                if 200..<300 ~= response.statusCode {
                    completion(json, nil)
                }
                else {
                    let error = (json as? JSON).flatMap(ServiceError.init) ?? ServiceError.other
                    
                    if error.errorDescription == "access token expired" {
                        log.warning("expired access token")
                        AuthService().refreshAccessToken(retryPath: path, retryMethod: method, retryParams: params, retryCompletion: completion)
                    }
                    else {
                        log.error(error)
                        completion(nil, error)
                    }
                }
            } else {
                let error = (json as? JSON).flatMap(ServiceError.init) ?? ServiceError.other
                log.error(error)
                completion(nil, error)
            }
        }
        
        task.resume()
        
        return task
    }
}


// build the complete API URL from given parameters
fileprivate extension URL {
    init(baseUrl: String, path: String, method: RequestMethod, params: JSON?) {
        // simply add the path to the base URL.
        var components = URLComponents(string: baseUrl)!
        components.path += path
        
        switch method {
        case .get, .delete:
            // For GET and DELETE methods, also add the query parameters to the URL string.
            if let params = params {
                components.queryItems = params.map {
                    URLQueryItem(name: $0.key, value: String(describing: $0.value))
                }
            }
        default:
            break
        }
        
        self = components.url!
    }
}

// build the instance of URLRequest from given parameters
fileprivate extension URLRequest {
    init(baseUrl: String, path: String, method: RequestMethod, params: JSON?) {
        let url = URL(baseUrl: baseUrl, path: path, method: method, params: params)
        
        self.init(url: url)
        
        httpMethod = method.rawValue
        
        setValue("application/json", forHTTPHeaderField: "Accept")
        setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let appName = Bundle.main.infoDictionary!["CFBundleName"] as? String,
            let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            let deviceModel = UIDevice.current.model
            let systemVersion = UIDevice.current.systemVersion
            let userAgent = "\(appName)/\(appVersion) (\(deviceModel); iOS \(systemVersion))"
            setValue(userAgent, forHTTPHeaderField: "User-Agent")
        }
        
        // set access token in headers if user has signed in
        if let token = Defaults[.accessToken], token.count > 0 {
            setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        }
        
        switch method {
        case .post, .put:
            // in case of POST or PUT HTTP methods, add parameters to the request body
            if let params = params {
                httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])
            }
        default:
            break
        }
    }
}
