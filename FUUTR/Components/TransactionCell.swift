//
//  TransactionCell.swift
//  FUUTR
//
//  Created by Chris Chen on 17/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {
  
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var balanceLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
  func loadTransaction(_ transaction: Transaction) {
    dateLabel.text = transaction.date?.dateTimeString
    amountLabel.text = transaction.amount?.priceString
    amountLabel.textColor = (transaction.amount! > 0) ? UIColor.primaryGreenColor : UIColor.primaryRedColor
    balanceLabel.text = transaction.balance?.priceString
  }
  
}
