//
//  String+Validate.swift
//  OTGRider
//
//  Created by Chris Chen on 31/10/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation

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
}
