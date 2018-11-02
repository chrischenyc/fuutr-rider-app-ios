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
        if indexPath.row == 3 {
            signOut()
        }
    }
    
    private func signOut() {
        // TODO: call API maybe?
        
        Defaults[.userSignedIn] = false
        // TODO: purge other user info in NSUserDefaults
        
        if FBSDKAccessToken.current() != nil {
            FBSDKLoginManager().logOut()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            self.perform(segue: StoryboardSegue.Settings.showSignIn)
        }
    }
    
}
