//
//  Double+Currency.swift
//  OTGRider
//
//  Created by Chris Chen on 9/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation

extension Double {
    var currencyString: String {
        return "$\(self)"
    }
}
