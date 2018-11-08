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
    static let userOnboarded = DefaultsKey<Bool>("com.otgride.userOnboarded")
    static let accessToken = DefaultsKey<String?>("com.otgride.accessToken")
    // TODO: jwt token refresh https://trello.com/c/JAThwebl/102-jwt-token-refresh
    static let refreshToken = DefaultsKey<String?>("com.otgride.refreshToken")
}
