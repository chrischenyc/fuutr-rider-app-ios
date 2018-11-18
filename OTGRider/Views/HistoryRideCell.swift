//
//  HistoryRideCell.swift
//  OTGRider
//
//  Created by Chris Chen on 17/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit

class HistoryRideCell: UITableViewCell {
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    
    func updateContent(withRide ride: Ride) {
        startTimeLabel.text = "Unlock: " + (ride.unlockTime?.dateTimeString)!
        endTimeLabel.text = "Lock: " + (ride.lockTime?.dateTimeString)!
        distanceLabel.text = "Distance: " + (ride.distance?.distanceString)!
        durationLabel.text = "Duration: " + (ride.duration?.hhmmssString)!
        costLabel.text = "Cost: " + (ride.totalCost?.currencyString)!
    }
}
