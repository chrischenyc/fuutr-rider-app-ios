//
//  Configuration.swift
//  FUUTR
//
//  Created by Chris Chen on 2/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
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
  case Development = "FUUTR-dev"
  case Staging = "FUUTR-staging"
  case Production = "FUUTR"
  
  var baseURL: String {
    switch self {
    case .Development: return "http://localhost:3000"
    case .Staging: return "https://api.staging.otgride.com"
    case .Production: return "https://api.fuutr.co"
    }
  }
  
  var googleMapKey: String {
    switch self {
    case .Development: fallthrough
    case .Staging: return "AIzaSyCj1ZxYDey7sjtQjpJGTy2sNfQkSoZakBQ"
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
  
  var termsURL: String {
    return "https://www.fuutr.co/terms"
  }
  
  var privacyURL: String {
    return "https://www.fuutr.co/privacy"
  }
  
  var helpURL: String {
    return "https://www.fuutr.co/help"
  }
  
  var contactURL: String {
    return "https://www.fuutr.co/contact"
  }
  
  var maxUploadSize: Int {
    return 1
  }
}
