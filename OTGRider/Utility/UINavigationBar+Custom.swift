//
//  UINavigationBar+Custom.swift
//  OTGRider
//
//  Created by Chris Chen on 7/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation

extension UINavigationBar {
  func applyTheme() {
    tintColor = UIColor.primaryDarkColor
    titleTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.primaryDarkColor
    ]
    largeTitleTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.primaryDarkColor
    ]
    setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    shadowImage = UIImage()
  }
}
