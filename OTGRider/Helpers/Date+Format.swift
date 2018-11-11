//
//  Date+Format.swift
//  OTGRider
//
//  Created by Chris Chen on 11/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation


extension Date {
    func dateTimeString() -> String {
        let dateFormatter = DateFormatter(withFormat: "MMM d, h:mm a", locale: "en_AU")
        return dateFormatter.string(from: self)
    }
}