//
//  TransactionCell.swift
//  OTGRider
//
//  Created by Chris Chen on 17/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func loadTransaction(_ transaction: Transaction) {
        amountLabel.text = transaction.amount?.currencyString
        balanceLabel.text = transaction.balance?.currencyString
        dateLabel.text = transaction.date?.dateTimeString ?? ""
        descriptionLabel.text = transaction.type
    }

}
