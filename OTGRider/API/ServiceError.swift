//
//  ServiceError.swift
//  OTGRider
//
//  Created by Chris Chen on 2/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation

enum ServiceError: Error {
    case noInternetConnection
    case custom(String) // Errors that reported as a part of the response (e.g. validation errors, insufficient access rights, etc.)
    case other  // Errors that the server fails to report as a part of the response (e.g. server crash, responses timing out, etc.)
}

extension ServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return NSLocalizedString("kNoInternetConnection", comment: "")
        case .custom(let message):
            return message
        case .other:
            return NSLocalizedString("kOtherError", comment: "")
        }
    }
}

//  transform the server JSON data into an error object
extension ServiceError {
    init(json: JSON) {
        if let message = json["message"] as? String {
            self = .custom(message)
        } else {
            self = .other
        }
    }
}
