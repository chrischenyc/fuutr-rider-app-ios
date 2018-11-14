//
//  UIViewControoler+Alert.swift
//  OTGRider
//
//  Created by Chris Chen on 3/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import UIKit

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
