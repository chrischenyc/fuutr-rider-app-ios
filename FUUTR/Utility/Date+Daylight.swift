//
//  NSDate+Daylight.swift
//  FUUTR
//
//  Created by Chris Chen on 20/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation
import EDSunriseSet

extension Date {
  func isDaylight() -> Bool {
    guard let currentLocation = currentLocation else { return true }
    guard let sunInfo = EDSunriseSet.sunriseset(withTimezone: TimeZone.current,
                                                latitude: currentLocation.coordinate.latitude,
                                                longitude: currentLocation.coordinate.longitude) else { return true }
    
    sunInfo.calculateSunriseSunset(self)
    
    guard let sunrise = sunInfo.sunrise,
      let sunset = sunInfo.sunset,
      let halfHourAfterSunrise = Calendar.current.date(byAdding: .minute, value: 30, to: sunrise),
      let halfHourBeforeSunset = Calendar.current.date(byAdding: .minute, value: -30, to: sunset) else { return true }
    
    return self > halfHourAfterSunrise && self < halfHourBeforeSunset
  }
}
