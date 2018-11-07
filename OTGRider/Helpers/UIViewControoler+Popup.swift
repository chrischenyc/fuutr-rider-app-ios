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

extension UIViewController {
    
    // normalize how error is displayed in UIViewController
    // currently use system alert view, may use custom UI in the future
    func showError(_ error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: L10n.kErrorConfirm, style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // normalize loading indicator while async task is running
    // currently use PKHUD, may need to use different UI in the future
    func showLoading(withMessage message: String? = nil) {
        if let message = message {
            HUD.show(HUDContentType.labeledProgress(title: message, subtitle: nil))
        } else {
            HUD.show(HUDContentType.progress)
        }
    }
    
    func dismissLoading(withMessage message: String? = nil) {
        if let message = message {
            HUD.flash(HUDContentType.label(message), delay: 2)
        } else {
            HUD.hide()
        }
    }
}
