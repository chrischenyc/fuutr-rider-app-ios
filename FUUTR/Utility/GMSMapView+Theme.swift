//
//  GMSMapView+Theme.swift
//  FUUTR
//
//  Created by Chris Chen on 29/1/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation
import GoogleMaps
import EDSunriseSet

extension GMSMapView {
  func applyTheme() {
    do {
      let themeJSON = Date().isDaylight() ? "GoogleMapStyle" : "GoogleMapStyle.night"
      
      if let styleURL = Bundle.main.url(forResource: themeJSON, withExtension: "json") {
        mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
      } else {
        logger.error("Unable to find \(themeJSON)")
      }
    }
    catch {
      logger.error("One or more of the map styles failed to load. \(error)")
    }
  }
}
