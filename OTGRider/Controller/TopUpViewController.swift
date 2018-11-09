//
//  TopUpViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 10/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit

class TopUpViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func amountChoosed(_ sender: Any) {
        perform(segue: StoryboardSegue.Account.fromTopUpToPaymentMethods, sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let choosePaymentMethodsViewController = segue.destination as? ChoosePaymentMethodsViewController {
            if let button = sender as? UIButton {
                if let amountString = button.titleLabel?.text {
                    choosePaymentMethodsViewController.paymentAmount = Double(amountString)
                }
            }
        }
    }
}
