//
//  HistoryRideCell.swift
//  FUUTR
//
//  Created by Chris Chen on 17/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import GoogleMaps

class HistoryRideCell: UITableViewCell {
  
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var startTimeLabel: UILabel!
  @IBOutlet weak var backdropView: UIView!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var costLabel: UILabel!
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    backdropView.layoutCornerRadiusMask(corners: [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner])
    mapView.applyTheme()
  }
  
  func updateContent(withRide ride: Ride) {
    startTimeLabel.text = ride.unlockTime?.dateTimeString
    distanceLabel.text = ride.distance.distanceString
    durationLabel.text = ride.duration.hhmmssString
    costLabel.text = ride.totalCost.priceStringWithoutCurrency
    mapView.drawRouteFor(ride: ride)
  }
}
