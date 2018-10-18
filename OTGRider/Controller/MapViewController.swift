//
//  MapViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 15/10/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        
        if let sideMenuViewController = sourceViewController as? SideMenuViewController,
            let selectedMenuItem = sideMenuViewController.selectedMenuItem {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                switch selectedMenuItem {
                case .wallet:
                    self.performSegue(withIdentifier: "showWallet", sender: nil)
                case .history:
                    self.performSegue(withIdentifier: "showHistory", sender: nil)
                case .juice:
                    self.performSegue(withIdentifier: "showJuice", sender: nil)
                case .settings:
                    self.performSegue(withIdentifier: "showSettings", sender: nil)
                case .help:
                    self.performSegue(withIdentifier: "showHelp", sender: nil)
                }
                
            })
        }
    }
    
    
}

