//
//  String+Validate.swift
//  OTGRider
//
//  Created by Chris Chen on 31/10/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import PhoneNumberKit

extension String {
    func isEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    func isValidPassword() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^(?=.*\\d).{6,16}$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    func isMobileNumber(_ completion: (Bool, UInt64?, String?) -> Void) {
        do {
            let phoneNumberKit = PhoneNumberKit()
            let phoneNumber = try phoneNumberKit.parse(self)
            completion(phoneNumber.type == .mobile, phoneNumber.countryCode, phoneNumber.numberString)
        } catch {
            completion(false, nil, nil)
        }
    }
    
    func isFourDigits() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[0-9]{4}$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
