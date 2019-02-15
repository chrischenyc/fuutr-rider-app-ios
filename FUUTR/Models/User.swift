//
//  User.swift
//  FUUTR
//
//  Created by Chris Chen on 11/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation
import ObjectMapper

struct User: Mappable {
  var displayName: String?
  var email: String?
  var countryCode: UInt64?
  var phoneNumber: String?
  var hasPassword: Bool?
  var photo: String?
  var balance: Double = 0
  var canReserveVehicleAfter: Date?
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    displayName             <- map["displayName"]
    email                   <- map["email"]
    countryCode             <- map["countryCode"]
    phoneNumber             <- map["phoneNumber"]
    hasPassword             <- map["hasPassword"]
    photo                   <- map["photo"]
    balance                 <- map["balance"]
    canReserveVehicleAfter  <- (map["canReserveVehicleAfter"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
  }
}


extension User {
  var formattedPhoneNumber: String {
    var result = ""
    if let theCountryCode = countryCode {
      result += "+\(theCountryCode) "
    }
    
    if let thePhoneNumber = phoneNumber {
      result += thePhoneNumber
    }
    
    return result
  }
}
