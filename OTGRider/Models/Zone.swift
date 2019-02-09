//
//  Zone.swift
//  FUUTR
//
//  Created by Chris Chen on 25/1/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation
import ObjectMapper

struct Zone: Mappable {
  var polygon: [[Double]] = []
  var parking: Bool = true
  var speedMode: Int = 0
  var title: String?
  var message: String?
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    polygon    <- map["polygon"]
    parking    <- map["parking"]
    speedMode  <- map["speedMode"]
    title      <- map["title"]
    message    <- map["message"]
  }
  
  static func fromJSONArray(_ jsonArray: [JSON]) -> [Zone]? {
    return Mapper<Zone>().mapArray(JSONArray: jsonArray)
  }
}
