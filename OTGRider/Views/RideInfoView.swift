//
//  RideInfoView.swift
//  OTGRider
//
//  Created by Chris Chen on 16/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation

class RideInfoView: UIView {
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    
    var onPauseRide: (()->Void)?
    var onEndRide: (()->Void)?
    
    func updateContent(withRide ride: Ride) {
        durationLabel.text = ride.duration.hhmmssString
        distanceLabel.text = ride.distance.distanceString
        costLabel.text = ride.totalCost.currencyString
        
        if ride.paused {
            pauseButton.setTitle("Unlock", for: .normal)
        } else {
            pauseButton.setTitle("Lock", for: .normal)
        }
    }
    
    @IBAction func pauseRideTapped(_ sender: Any) {
        onPauseRide?()
    }
    
    @IBAction func endRide(_ sender: Any) {
        onEndRide?();
    }
}
