//
//  SideMenuViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 17/10/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit

enum SideMenuItem {
    case greeting
    case history
    case wallet
    case juice
    case settings
    case help
}

class SideMenuViewController: UITableViewController {
    
    var selectedMenuItem: SideMenuItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 1:
            selectedMenuItem = .history
            performSegue(withIdentifier: "unwindToHome", sender: nil)
        case 2:
            selectedMenuItem = .wallet
            performSegue(withIdentifier: "unwindToHome", sender: nil)
        case 3:
            selectedMenuItem = .juice
            performSegue(withIdentifier: "unwindToHome", sender: nil)
        case 4:
            selectedMenuItem = .settings
            performSegue(withIdentifier: "unwindToHome", sender: nil)
        case 5:
            selectedMenuItem = .help
            performSegue(withIdentifier: "unwindToHome", sender: nil)
        default:
            break
        }
    }
    
    
}
