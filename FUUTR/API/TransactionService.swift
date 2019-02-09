//
//  TransactionService.swift
//  FUUTR
//
//  Created by Chris Chen on 17/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation

final class TransactionService {
  
  static func getHistoryTransactions(completion: @escaping ([Transaction]?, Error?) -> Void) -> URLSessionDataTask? {
    return APIClient.shared.load(path: "/transactions/me",
                                 method: .get,
                                 params: nil,
                                 completion: { (result, error) in
                                  if let jsonArray = result as? [JSON] {
                                    completion(Transaction.fromJSONArray(jsonArray), nil)
                                    return
                                  }
                                  
                                  completion(nil, error)
    })
  }
}

