//
//  UIViewController+HUD.swift
//  FUUTR
//
//  Created by Chris Chen on 14/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation
import PKHUD

// normalize loading indicator while async task is running
// currently use PKHUD, may need to use different UI in the future
extension UIViewController {
  
  func showLoading() {
    HUD.show(.progress)
  }
  
  func dismissLoading(completion: ((Bool) -> Void)? = nil) {
    HUD.hide(completion)
  }
}
