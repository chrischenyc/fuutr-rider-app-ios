//
//  UIViewControoler+Alert.swift
//  OTGRider
//
//  Created by Chris Chen on 3/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
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
        alertMessage(title: nil,
                     message: error.localizedDescription,
                     positiveActionButtonTitle: "OK",
                     positiveActionButtonTapped: {
                        actionButtonTapped?()
        })
    }
    
    func alertMessage(title: String? = nil,
                      message: String?,
                      image: UIImage? = nil,
                      positiveActionButtonTitle: String? = nil,
                      positiveActionButtonTapped: (()->Void)? = nil,
                      negativeActionButtonTitle: String? = nil,
                      negativeActionButtonTapped: (()->Void)? = nil) {
        var formSheetController: MZFormSheetPresentationViewController!
        
        let viewController = DialogViewController(title: title,
                                                  message: message,
                                                  image: image,
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
