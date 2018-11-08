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
    
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    private var userServiceTask: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
        displayNameLabel.text = ""
        phoneNumberLabel.text = ""
        emailLabel.text = ""
        
        loadProfile()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 3 {
            signOut()
        }
    }
    
    private func signOut() {
        DispatchQueue.main.async {
            Defaults[.userSignedIn] = false
            Defaults[.accessToken] = ""
            Defaults[.refreshToken] = ""
            
            if FBSDKAccessToken.current() != nil {
                FBSDKLoginManager().logOut()
            }
            
            self.perform(segue: StoryboardSegue.Settings.showSignIn)
        }
    }
    
    private func loadProfile() {
        userServiceTask?.cancel()
        
        showLoading()
        
        userServiceTask = UserService().getProfile({[weak self] (result, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    self?.dismissLoading(withMessage: error?.localizedDescription)
                    return
                }
                
                guard let profile = result as? JSON else {
                    self?.dismissLoading(withMessage: L10n.kOtherError)
                    return
                }
                
                self?.dismissLoading()
                self?.displayNameLabel.text = profile["displayName"] as? String ?? ""
                self?.phoneNumberLabel.text = profile["phoneNumber"] as? String ?? ""
                self?.emailLabel.text = profile["email"] as? String ?? ""
            }
        })
    }
}
