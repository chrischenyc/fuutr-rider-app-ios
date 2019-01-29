//
//  PaymentCell.swift
//  OTGRider
//
//  Created by Chris Chen on 11/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit

class PaymentCell: UITableViewCell {

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func loadPayment(_ payment: Payment) {
        amountLabel.text = payment.amount?.currencyString
        
        dateLabel.text = payment.date?.dateTimeString ?? ""
        
        var paymentDescription = ""
        if let description = payment.description {
            paymentDescription += description
        }
        if let lastFour = payment.lastFour {
            paymentDescription += " paid with \(lastFour)"
        }
        descriptionLabel.text = paymentDescription
    }

}
