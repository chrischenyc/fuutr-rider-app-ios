//
//  SideMenuViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 17/10/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit

// arrange enums according to the order of static cells in SideMenu.storyboard
enum SideMenuItem: Int {
    case greeting
    case history
    case accont
    case settings
    case help
}

class SideMenuViewController: UITableViewController {
    
    var selectedMenuItem: SideMenuItem?
    
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appName = Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String,
            let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String,
            let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as? String {
            versionLabel.text = "\(appName) \(appVersion)(\(buildNumber))"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMenuItem = SideMenuItem(rawValue: indexPath.row)
        
        guard let selectedMenuItem = selectedMenuItem else { return }
        
        switch selectedMenuItem {
        case .greeting:
            break
        case .history,
             .settings,
             .accont,
             .help:
            perform(segue: StoryboardSegue.SideMenu.showMain)
        }
    }
    
}
