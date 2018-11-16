//
//  RideInfoView.swift
//  OTGRider
//
//  Created by Chris Chen on 16/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation

class RideInfoView: UIView {
    
    @IBOutlet weak var scooterInfoLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    var onHowToTapped: (()->Void)?
    
    func updateContent(withRide ride: Ride) {
        scooterInfoLabel.text = "Scooter \(ride.vehicleCode ?? "n/a")"
        
        if let duration = ride.duration {
            durationLabel.text = duration.hhmmssString()
        }
        else {
            durationLabel.text = "n/a"
        }
        
        distanceLabel.text = "n/a"
        costLabel.text = ride.totalCost?.currencyString ?? "n/a"
    }
    
    @IBAction func howToTapped(_ sender: Any) {
        onHowToTapped?()
    }
}
