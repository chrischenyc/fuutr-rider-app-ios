//
//  ZoneService.swift
//  OTGRider
//
//  Created by Chris Chen on 25/1/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation

final class ZoneService {
  static func search(_ completion: @escaping ([Zone]?, Error?) -> Void) -> URLSessionDataTask? {
    
    return APIClient.shared.load(path: "/zones",
                                 method: .get,
                                 params: nil,
                                 completion: { (result, error) in
                                  if let jsonArray = result as? [JSON] {
                                    let zones = Zone.fromJSONArray(jsonArray)
                                    completion(zones, nil)
                                    return
                                  }
                                  
                                  completion(nil, error)
    })
  }
}
