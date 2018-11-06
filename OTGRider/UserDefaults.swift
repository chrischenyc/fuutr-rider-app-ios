//
//  UserDefaults.swift
//  OTGRider
//
//  Created by Chris Chen on 31/10/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let userSignedIn = DefaultsKey<Bool>("com.otgride.userSignedIn")
    static let userToken = DefaultsKey<String?>("com.otgride.userToken")
    static let userOnboarded = DefaultsKey<Bool>("com.otgride.userOnboarded")
}
