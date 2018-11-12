//
//  UIViewControoler+Popup.swift
//  OTGRider
//
//  Created by Chris Chen on 3/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import UIKit
import PKHUD

// normalize how error/message is presented modally in UIViewController
// currently use system alert view, may use custom UI in the future
extension UIViewController {
    
    func showError(_ error: Error,
                   actionButtonTitle: String? = nil,
                   actionButtonTapped: (()->Void)? = nil) {
        showMessage(error.localizedDescription,
                    actionButtonTitle: actionButtonTitle,
                    actionButtonTapped: actionButtonTapped)
    }
    
    func showMessage(_ message: String,
                     actionButtonTitle: String? = nil,
                     actionButtonTapped: (()->Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        
        if let actionButtonTitle = actionButtonTitle {
            let action = UIAlertAction(title: actionButtonTitle, style: .default) { (alertAction) in
                actionButtonTapped?()
            }
            alert.addAction(action)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
        else {
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
}

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
        HUD.flash(.labeledImage(image: nil, title: "Error", subtitle: message),
                  onView: nil,
                  delay: 2.0,
                  completion: completion)
    }
}
