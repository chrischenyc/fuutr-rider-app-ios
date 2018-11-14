//
//  ScooterInfoView.swift
//  OTGRider
//
//  Created by Chris Chen on 14/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit

class ScooterInfoView: UIView {
    
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var pricingLabel: UILabel!
    
    @IBAction func tootButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func reportButtonTapped(_ sender: Any) {
        
    }
    
    func updateContentWith(scooter: ScooterPOIItem) {
        if let powerPercent = scooter.powerPercent {
            batteryLabel.text = "Battery \(powerPercent)%"
        } else {
            batteryLabel.text = "Battery N/A"
        }
        
        if let remainderRange = scooter.remainderRange {
            rangeLabel.text = "Range \(remainderRange)km"
        } else {
            rangeLabel.text = "Range N/A"
        }
        
        pricingLabel.text = "Unlock for $1 + $0.20/min"
    }
}
