//
//  SettingsTableViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 1/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import FBSDKLoginKit

class SettingsTableViewController: UITableViewController {
  
  @IBOutlet weak var displayNameLabel: UILabel!
  @IBOutlet weak var phoneNumberLabel: UILabel!
  @IBOutlet weak var emailLabel: UILabel!
  
  private var apiTask: URLSessionTask?
  private var user: User?
  
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
  
  @IBAction func unwindToSettings(_ unwindSegue: UIStoryboardSegue) {
    loadProfile()
  }
  
  private func signOut() {
    _ = AuthService.logout { (error) in
      guard error == nil else {
        logger.error(error?.localizedDescription)
        return
      }
    }
    
    Defaults[.userSignedIn] = false
    Defaults[.accessToken] = ""
    Defaults[.refreshToken] = ""
    if FBSDKAccessToken.current() != nil {
      FBSDKLoginManager().logOut()
    }
    
    NotificationCenter.default.post(name: .userSignedOut, object: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let editNameViewController = segue.destination as? EditNameViewController {
      editNameViewController.displayName = user?.displayName
    }
    else if let editEmailViewController = segue.destination as? EditEmailViewController {
      editEmailViewController.email = user?.email
    }
    else if let editPhoneViewController = segue.destination as? EditPhoneViewController {
      editPhoneViewController.countryCode = user?.countryCode
      editPhoneViewController.phoneNumber = user?.phoneNumber
    }
  }
  
  private func loadProfile() {
    apiTask?.cancel()
    
    showLoading()
    
    apiTask = UserService.getProfile({[weak self] (user, error) in
      DispatchQueue.main.async {
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        guard let user = user else {
          self?.alertMessage(message: R.string.localizable.kOtherError())
          return
        }
        
        self?.dismissLoading()
        self?.loadUserContent(user)
        
        self?.user = user
      }
    })
  }
  
  private func loadUserContent(_ user: User) {
    self.displayNameLabel.text = user.displayName
    self.phoneNumberLabel.text = user.phoneNumber
    self.emailLabel.text = user.email
  }
}