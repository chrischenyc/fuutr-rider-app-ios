//
//  TopUpViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 10/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit

class TopUpViewController: UIViewController {
    
    var paymentAmount: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func amountChoosed(_ sender: Any) {
        if let button = sender as? UIButton, let amountString = button.titleLabel?.text {
            paymentAmount = Double(amountString)
        }
        
        perform(segue: StoryboardSegue.Account.fromTopUpToPaymentMethods, sender: sender)
    }
}
