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
    static let userSignedIn = DefaultsKey<Bool>("userSignedIn")
    static let userOnboarded = DefaultsKey<Bool>("userOnboarded")
}
