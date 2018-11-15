//
//  UIViewController+HUD.swift
//  OTGRider
//
//  Created by Chris Chen on 14/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import PKHUD

// normalize loading indicator while async task is running
// currently use PKHUD, may need to use different UI in the future
extension UIViewController {
    
    func showLoading(withMessage message: String? = nil) {
        if let message = message {
            HUD.show(.labeledProgress(title: message, subtitle: nil))
        } else {
            HUD.show(.progress)
        }
    }
    
    func dismissLoading(completion: ((Bool) -> Void)? = nil) {
        HUD.hide(completion)
    }
    
    func flashMessage(_ message: String?, completion: ((Bool) -> Void)? = nil) {
        HUD.flash(.label(message),
                  onView: nil,
                  delay: 2.0,
                  completion: completion)
    }
    
    func flashSuccessMessage(_ message: String?, completion: ((Bool) -> Void)? = nil) {
        HUD.flash(.labeledSuccess(title: "Success", subtitle: message),
                  onView: nil,
                  delay: 2.0,
                  completion: completion)
    }
    
    func flashErrorMessage(_ message: String?, completion: ((Bool) -> Void)? = nil) {
        flashMessage(message, completion: completion)
    }
}
