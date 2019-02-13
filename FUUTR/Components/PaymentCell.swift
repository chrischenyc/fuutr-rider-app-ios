//
//  PaymentCell.swift
//  FUUTR
//
//  Created by Chris Chen on 11/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit

class PaymentCell: UITableViewCell {
  
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
  func loadPayment(_ payment: Payment) {
    amountLabel.text = payment.amount?.priceString
    dateLabel.text = payment.date?.dateTimeString
  }
  
}
