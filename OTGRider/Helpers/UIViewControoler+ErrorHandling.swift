//
//  UIViewControoler+ErrorHandling.swift
//  OTGRider
//
//  Created by Chris Chen on 3/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import UIKit

// normalize how error is displayed in UIViewController
// currently use system alert view, may use custom UI in the future
extension UIViewController {
    func showError(_ error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: L10n.kErrorConfirm, style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
