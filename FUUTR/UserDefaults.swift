//
//  UserDefaults.swift
//  FUUTR
//
//  Created by Chris Chen on 31/10/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
  static let userSignedIn = DefaultsKey<Bool>("co.fuutr.userSignedIn")
  static let userOnboarded = DefaultsKey<Bool>("co.fuutr.userOnboarded")
  static let userTrainedHowToRide = DefaultsKey<Bool>("co.fuutr.userTrainedHowToRide")
  static let accessToken = DefaultsKey<String?>("co.fuutr.accessToken")
  static let refreshToken = DefaultsKey<String?>("co.fuutr.refreshToken")
}
