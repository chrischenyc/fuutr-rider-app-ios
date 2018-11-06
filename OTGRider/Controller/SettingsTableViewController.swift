//
//  SettingsTableViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 1/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import FBSDKLoginKit

class SettingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 3 {
            signOut()
        }
    }
    
    private func signOut() {
        Defaults[.userSignedIn] = false
        Defaults[.userToken] = nil
        
        if FBSDKAccessToken.current() != nil {
            FBSDKLoginManager().logOut()
        }
        
        self.perform(segue: StoryboardSegue.Settings.showSignIn)
    }
    
}
