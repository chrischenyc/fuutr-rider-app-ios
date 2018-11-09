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
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
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
        let regex = "^[0-9]{4}$"
        
        let test = NSPredicate(format:"SELF MATCHES %@", regex)
        return test.evaluate(with: self)
    }
}
