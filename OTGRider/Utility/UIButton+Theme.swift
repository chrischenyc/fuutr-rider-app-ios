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
        layer.cornerRadius = .defaultCornerRadius
        setTitleColor(UIColor.white, for: .normal)
    }
    
    // TODO: font style
    func primaryRedBasic() {
        backgroundColor = UIColor.clear
        layer.borderColor = UIColor.primaryRedColor.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = .defaultCornerRadius
        setTitleColor(UIColor.primaryRedColor, for: .normal)
    }
    
    // TODO: font style
    func primaryDarkBasic() {
        backgroundColor = UIColor.clear
        setTitleColor(UIColor.primaryDarkColor, for: .normal)
    }
}
