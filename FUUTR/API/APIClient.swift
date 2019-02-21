//
//  APIClient.swift
//  FUUTR
//
//  Created by Chris Chen on 2/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation
import Reachability
import SwiftyUserDefaults

enum RequestMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case patch = "PATCH"
  case delete = "DELETE"
}

final class APIClient {
  static let shared: APIClient = {
    let client = APIClient(baseURL: config.env.baseURL)
    
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
            image: UIImage? = nil,
            completion: @escaping (Any?, Error?) -> Void) -> URLSessionDataTask? {
    
    // Checking internet connection availability
    guard let reachablity = Reachability(hostname: baseURL), reachablity.connection != .none else {
      logger.warning(ServiceError.noInternetConnection)
      completion(nil, ServiceError.noInternetConnection)
      return nil
    }
    
    // Creating the URLRequest object
    var request = URLRequest(baseUrl: baseURL, path: path, method: method, params: params)
    
    if let image = image {
      // generate boundary string using a unique per-app string
      let boundary = UUID().uuidString
      
      // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
      // And the boundary is also set here
      request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
      
      // create multi-form data
      var requestData = Data()
      
      // Convert other params into multi-form data
      if let params = params {
        params.forEach { (fieldName, fieldValue) in
          requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
          requestData.append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n".data(using: .utf8)!)
          requestData.append("\(fieldValue)".data(using: .utf8)!)
        }
      }
      
      // Add the image data to the raw http request data
      requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
      requestData.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
      requestData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
      // requestData.append(image.jpegData(compressionQuality: 1.0)!)
      requestData.append(image.jpegDataWithSizeLimit(config.env.maxUploadSize)!)
      
      // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
      // According to the HTTP 1.1 specification https://tools.ietf.org/html/rfc7230
      requestData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
      
      // Sending request to the server.
      let task = URLSession.shared.uploadTask(with: request, from: requestData) { (data, response, error) in
        self.requestCompletionHandler(data: data,
                                      response: response,
                                      error: error,
                                      completion: completion,
                                      path: path,
                                      method: method,
                                      params: params)
      }
      
      task.resume()
      
      return task
    }
    else {
      // Sending request to the server.
      let task = URLSession.shared.dataTask(with: request) { data, response, error in
        self.requestCompletionHandler(data: data,
                                      response: response,
                                      error: error,
                                      completion: completion,
                                      path: path,
                                      method: method,
                                      params: params)
      }
      
      task.resume()
      
      return task
    }
    
  }
  
  private func requestCompletionHandler(data: Data?,
                                        response: URLResponse?,
                                        error: Error?,
                                        completion: @escaping (Any?, Error?) -> Void,
                                        path: String,
                                        method: RequestMethod,
                                        params: JSON?) {
    guard error == nil else {
      logger.error(error!.localizedDescription)
      completion(nil, error)
      return
    }
    
    guard let data = data else {
      logger.error("missing payload")
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
          logger.warning("expired access token")
          AuthService.refreshAccessToken(retryPath: path, retryMethod: method, retryParams: params, retryCompletion: completion)
        }
        else {
          logger.error(error)
          completion(nil, error)
        }
      }
    } else {
      let error = (json as? JSON).flatMap(ServiceError.init) ?? ServiceError.other
      logger.error(error)
      completion(nil, error)
    }
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
    case .post, .put, .patch:
      // in case of POST or PUT HTTP methods, add parameters to the request body
      if let params = params {
        httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])
      }
    default:
      break
    }
  }
}
