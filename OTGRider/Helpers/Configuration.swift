//
//  Configuration.swift
//  OTGRider
//
//  Created by Chris Chen on 2/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation

struct Configuration {
    lazy var env: Environment = {
        guard let target = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String
            else { return Environment.Development }
        
        guard let environment = Environment(rawValue: target) else { return Environment.Development }
        
        return environment
    }()
}

enum Environment: String {
    case Development = "OTGRider-dev"
    case Staging = "OTGRider-staging"
    case Production = "OTGRider"
    
    var baseURL: String {
        switch self {
        case .Development: return "http://localhost:3000/api"
        case .Staging: return "http://ec2-13-239-12-227.ap-southeast-2.compute.amazonaws.com/api"
        case .Production: return ""
        }
    }
    
    var googleMapKey: String {
        switch self {
        case .Development: fallthrough
        case .Staging: return "AIzaSyA2kZ3cVDtKRB9U3WkThBh1fBn0IBGa-VE"
        case .Production: return ""
        }
    }
    
    var stripePublishableKey: String {
        switch self {
        case .Development: return "pk_test_B8EZVlHA6MEaz7U7JrH5qPdm"
        case .Staging: return "pk_test_spkqNTdgZjMoHsKecPyReuo8"
        case .Production: return ""
        }
    }
    
    var appleMerchantIdentifier: String {
        switch self {
        case .Development: return "merchant.xyz"    // placeholder when testing in the iOS simulator
        case .Staging: return "merchant.com.capturedlabs.otgride.staging"
        case .Production: return ""
        }
    }
}
