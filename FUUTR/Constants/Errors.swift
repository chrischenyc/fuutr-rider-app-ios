//
//  Errors.swift
//  FUUTR
//
//  Created by Chris Chen on 1/3/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation

enum AppError: Error {
  case lowBalance
}

enum NetworkError: Error {
  case noInternetConnection
  case custom(String) // Errors that reported as a part of the response (e.g. validation errors, insufficient access rights, etc.)
  case other  // Errors that the server fails to report as a part of the response (e.g. server crash, responses timing out, etc.)
}

extension NetworkError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .noInternetConnection:
      return R.string.localizable.kNoInternetConnection()
    case .custom(let message):
      return message
    case .other:
      return R.string.localizable.kOtherError()
    }
  }
}

//  transform the server JSON data into an error object
extension NetworkError {
  init(json: JSON) {
    if let message = json["error"] as? String {
      self = .custom(message)
    } else {
      self = .other
    }
  }
}
