//
//  UIViewControoler+Alert.swift
//  OTGRider
//
//  Created by Chris Chen on 3/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import UIKit
import MZFormSheetPresentationController

// normalize how error/message is presented modally in UIViewController
// currently use system alert view, may use custom UI in the future
extension UIViewController {
    
    func alertError(_ error: Error,
                    actionButtonTitle: String? = nil,
                    actionButtonTapped: (()->Void)? = nil) {
        alertMessage(error.localizedDescription,
                     actionButtonTitle: actionButtonTitle,
                     actionButtonTapped: actionButtonTapped)
    }
    
    func alertMessage(_ message: String,
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
    
    func alertMessage(_ title: String,
                      _ message: String,
                      positiveActionButtonTitle: String?,
                      positiveActionButtonTapped: (()->Void)?,
                      negativeActionButtonTitle: String? = nil,
                      negativeActionButtonTapped: (()->Void)? = nil) {
        var formSheetController: MZFormSheetPresentationViewController!
        
        let viewController = DialogViewController(title: title,
                                                  message: message,
                                                  positiveActionButtonTitle: positiveActionButtonTitle,
                                                  positiveActionButtonTapped: {
                                                    formSheetController.dismiss(animated: true, completion: {
                                                        positiveActionButtonTapped?()
                                                    })
        },
                                                  negativeActionButtonTitle: negativeActionButtonTitle,
                                                  negativeActionButtonTapped: {
                                                    formSheetController.dismiss(animated: true, completion: {
                                                        negativeActionButtonTapped?()
                                                    })
        })
        viewController.message = message
        
        formSheetController = MZFormSheetPresentationViewController(contentViewController: viewController)
        formSheetController.contentViewControllerTransitionStyle = .bounce
        formSheetController.presentationController?.shouldCenterVertically = true
        formSheetController.presentationController?.contentViewSize = UIView.layoutFittingCompressedSize
        
        present(formSheetController, animated: true, completion: nil)
    }
}
