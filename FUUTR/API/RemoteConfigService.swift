//
//  RemoteConfigService.swift
//  FUUTR
//
//  Created by Chris Chen on 12/02/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

final class RemoteConfigService {
  static func getConfig(_ completion: @escaping (RemoteConfig?, Error?) -> Void) -> URLSessionDataTask? {
    return APIClient.shared.load(path: "/remoteConfig",
                                 method: .get,
                                 params: nil,
                                 completion: { (result, error) in
                                  if let json = result as? JSON, let config = RemoteConfig(JSON: json) {
                                    completion(config, nil)
                                    return
                                  }
                                  
                                  completion(nil, error)
    })
  }
}

