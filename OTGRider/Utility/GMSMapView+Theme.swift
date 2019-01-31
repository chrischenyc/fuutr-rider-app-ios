//
//  GMSMapView+Theme.swift
//  OTGRider
//
//  Created by Chris Chen on 29/1/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation
import GoogleMaps
import Solar

extension GMSMapView {
  func applyTheme(currentLocation: CLLocation? = nil) {
    do {
      var themeJSON = "GoogleMapStyle"
      
      if let currentLocation = currentLocation,
        let solar = Solar(coordinate: currentLocation.coordinate),
        solar.isNighttime {
        themeJSON = "GoogleMapStyle.night"
      }
      
      if let styleURL = Bundle.main.url(forResource: themeJSON, withExtension: "json") {
        mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
      } else {
        logger.error("Unable to find style.json")
      }
    }
    catch {
      logger.error("One or more of the map styles failed to load. \(error)")
    }
  }
}