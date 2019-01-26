//
//  UIButton+Theme.swift
//  OTGRider
//
//  Created by Chris Chen on 26/1/19.
//  Copyright © 2019 OTGRide. All rights reserved.
//

import Foundation

extension UIButton {
    func primaryRed() {
        backgroundColor = UIColor.primaryRedColor
        titleLabel?.textColor = UIColor.white
        layer.cornerRadius = 5
    }
}
