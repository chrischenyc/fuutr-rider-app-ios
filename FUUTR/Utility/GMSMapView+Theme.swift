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
      var themeJSON = "GoogleMapStyle"
      
      if let currentLocation = currentLocation,
        let sunInfo = EDSunriseSet.sunriseset(withTimezone: TimeZone.current, latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude) {
        let now = Date()
        sunInfo.calculateSunriseSunset(now)
        
        if let sunrise = sunInfo.sunrise,
          let sunset = sunInfo.sunset,
          let halfHourAfterSunrise = Calendar.current.date(byAdding: .minute, value: 30, to: sunrise),
          let halfHourBeforeSunset = Calendar.current.date(byAdding: .minute, value: -30, to: sunset),
          now <=  halfHourAfterSunrise || now >= halfHourBeforeSunset {
          themeJSON = "GoogleMapStyle.night"
        }
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
