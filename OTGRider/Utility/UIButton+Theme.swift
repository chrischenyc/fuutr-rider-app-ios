//
//  UIButton+Theme.swift
//  OTGRider
//
//  Created by Chris Chen on 26/1/19.
//  Copyright © 2019 OTGRide. All rights reserved.
//

import Foundation

extension UIButton {
    // TODO: font style
    func primaryRed() {
        backgroundColor = UIColor.primaryRedColor
        layer.cornerRadius = 5
        titleLabel?.textColor = UIColor.white
    }
    
    // TODO: font style
    func primaryRedBasic() {
        backgroundColor = UIColor.clear
        layer.borderColor = UIColor.primaryRedColor.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 5
        titleLabel?.textColor = UIColor.primaryRedColor
    }
}
