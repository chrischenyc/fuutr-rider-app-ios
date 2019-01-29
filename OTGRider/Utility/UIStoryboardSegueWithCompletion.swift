//
//  UIStoryboardSegueWithCompletion.swift
//  OTGRider
//
//  Created by Chris Chen on 3/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit

// https://stackoverflow.com/questions/27483881/perform-push-segue-after-an-unwind-segue
class UIStoryboardSegueWithCompletion: UIStoryboardSegue {
    var completion: (() -> Void)?
    
    override func perform() {
        super.perform()
        
        if let completion = completion {
            completion()
        }
    }
}
