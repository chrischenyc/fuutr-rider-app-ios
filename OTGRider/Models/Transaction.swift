//
//  Transaction.swift
//  OTGRider
//
//  Created by Chris Chen on 17/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation
import ObjectMapper

struct Transaction: Mappable {
    var amount: Double?
    var type: String?
    var balance: Double?
    var date: Date?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        amount          <- map["amount"]
        type            <- map["type"]
        balance         <- map["balance"]
        date            <- (map["createdAt"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
    }
    
    static func fromJSONArray(_ jsonArray: [JSON]) -> [Transaction]? {
        return Mapper<Transaction>().mapArray(JSONArray: jsonArray)
    }
}
