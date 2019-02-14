//
//  UINavigationBar+Custom.swift
//  FUUTR
//
//  Created by Chris Chen on 7/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation

extension UINavigationBar {
  func applyLightTheme(transparentBackground: Bool = true) {
    tintColor = UIColor.primaryDarkColor
    titleTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.primaryDarkColor
    ]
    largeTitleTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.primaryDarkColor
    ]
    
    if transparentBackground {
      setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    }
    
    shadowImage = UIImage()
  }
  
  func applyDarkTheme(transparentBackground: Bool = true) {
    tintColor = UIColor.white
    titleTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.white
    ]
    largeTitleTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.white
    ]
    
    if transparentBackground {
      setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    }
    
    shadowImage = UIImage()
  }
}
