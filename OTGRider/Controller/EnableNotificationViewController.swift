//
//  EnableNotificationViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 31/10/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class EnableNotificationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

   
    @IBAction func enableNotificationTapped(_ sender: Any) {
        // TODO: request push notification permission
        Defaults[.userOnboarded] = true
        
        perform(segue: StoryboardSegue.Onboard.showMain, sender: nil)
    }
    
}
