//
//  APIClient.swift
//  OTGRider
//
//  Created by Chris Chen on 2/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import Reachability

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
              params: JSON,
              completion: @escaping APIResponse) -> URLSessionDataTask? {
        
        // Checking internet connection availability
        guard let reachablity = Reachability(hostname: baseURL), reachablity.connection != .none else {
            log.warning(ServiceError.noInternetConnection)
            completion(nil, ServiceError.noInternetConnection)
            return nil
        }
        
        
        // Creating the URLRequest object
        let request = URLRequest(baseUrl: baseURL, path: path, method: method, params: params)
        log.debug(request.url?.absoluteString ?? "INVALID URL")
        
        // Sending request to the server.
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                log.error(error!.localizedDescription)
                completion(nil, ServiceError.other)
                return
            }
            
            guard let data = data else {
                log.error("missing payload")
                completion(nil, ServiceError.other)
                return
            }
            
            // Parsing incoming data
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode {
                completion(json, nil)
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
    init(baseUrl: String, path: String, method: RequestMethod, params: JSON) {
        // simply add the path to the base URL.
        var components = URLComponents(string: baseUrl)!
        components.path += path
        
        switch method {
        case .get, .delete:
            // For GET and DELETE methods, also add the query parameters to the URL string.
            components.queryItems = params.map {
                URLQueryItem(name: $0.key, value: String(describing: $0.value))
            }
        default:
            break
        }
        
        self = components.url!
    }
}

// build the instance of URLRequest from given parameters
fileprivate extension URLRequest {
    init(baseUrl: String, path: String, method: RequestMethod, params: JSON) {
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
        
        // TODO: auth token if user has signed in
        setValue("Bearer " + "token", forHTTPHeaderField: "Authorization")
        
        switch method {
        case .post, .put:
            // in case of POST or PUT HTTP methods, add parameters to the request body
            httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])
        default:
            break
        }
    }
}
