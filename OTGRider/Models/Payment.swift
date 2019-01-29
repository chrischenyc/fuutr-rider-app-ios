//
//  Payment.swift
//  OTGRider
//
//  Created by Chris Chen on 11/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation
import ObjectMapper

struct Payment: Mappable {
  var amount: Double?
  var lastFour: String?
  var description: String?
  var date: Date?
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    amount          <- map["amount"]
    lastFour        <- map["lastFour"]
    description     <- map["description"]
    date            <- (map["createdAt"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
  }
  
  static func fromJSONArray(_ jsonArray: [JSON]) -> [Payment]? {
    return Mapper<Payment>().mapArray(JSONArray: jsonArray)
  }
}
