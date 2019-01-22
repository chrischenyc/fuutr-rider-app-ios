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
        if let duration = ride.duration {
            durationLabel.text = duration.hhmmssString
        }
        else {
            durationLabel.text = "n/a"
        }
        
        if let distance = ride.distance {
            distanceLabel.text = distance.distanceString
        } else {
            distanceLabel.text = "n/a"
        }
        
        costLabel.text = ride.totalCost?.currencyString ?? "n/a"
        
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
