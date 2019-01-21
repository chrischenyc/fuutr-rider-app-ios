//
//  VehicleInfoView.swift
//  OTGRider
//
//  Created by Chris Chen on 14/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit

class VehicleInfoView: UIView {
    var vehicle: Vehicle?
    
    @IBOutlet weak var vehicleCodeLabel: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var pricingLabel: UILabel!
    @IBOutlet weak var reserveButton: UIButton!
    
    var onReserve: ((Vehicle)->Void)?
    
    @IBAction func tootButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func reportButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func reserveButtonTapped(_ sender: Any) {
        guard let vehicle = vehicle else { return }
        guard let onReserve = onReserve else { return }
        
        onReserve(vehicle)
    }
    
    
    func updateContentWith(_ vehicle: Vehicle) {
        self.vehicle = vehicle
        
        if let vehicleCode = vehicle.vehicleCode {
            vehicleCodeLabel.text = vehicleCode
        }
        else {
            vehicleCodeLabel.text = "N/A"
        }
        
        if let powerPercent = vehicle.powerPercent {
            batteryLabel.text = "Battery \(powerPercent)%"
        } else {
            batteryLabel.text = "Battery N/A"
        }
        
        if let remainderRange = vehicle.remainderRange {
            rangeLabel.text = "Range \(remainderRange)km"
        } else {
            rangeLabel.text = "Range N/A"
        }
        
        pricingLabel.text = "Unlock for $1 + $0.20/min"
        
        if vehicle.reserved {
            // TODO: create timer to update counter
            reserveButton.setTitle("Reserved for next ", for: .normal)
        } else {
            reserveButton.setTitle("Reserve", for: .normal)
        }
    }
}
