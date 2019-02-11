//
//  SideMenuViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 17/10/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit

// arrange enums according to the order of static cells in SideMenu.storyboard
enum SideMenuItem: Int {
  case history
  case wallet
  case account
  case help
}

class SideMenuViewController: UIViewController {
  
  @IBOutlet weak var greetingBackdropView: UIView!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var greetingLabel: UILabel!
  @IBOutlet weak var rideHistoryButton: UIButton!
  @IBOutlet weak var walletButton: UIButton!
  @IBOutlet weak var accountButton: UIButton!
  @IBOutlet weak var helpButton: UIButton!
  
  var selectedMenuItem: SideMenuItem?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    greetingBackdropView.backgroundColor = UIColor.primaryRedColor
    if let displayName = currentUser?.displayName {
      greetingLabel.text = "Hi, \(displayName)!"
    }
    else {
      greetingLabel.text = "Hi!"
    }
    
    rideHistoryButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    walletButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    accountButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    helpButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    rideHistoryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
    walletButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
    accountButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
    helpButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
  }
  
  @IBAction func menuItemSelected(_ sender: Any) {
    if let button = sender as? UIButton {
      switch button {
      case rideHistoryButton:
        selectedMenuItem = .history
      case walletButton:
        selectedMenuItem = .wallet
      case accountButton:
        selectedMenuItem = .account
      case helpButton:
        selectedMenuItem = .help
      default:
        break
      }
      
      performSegue(withIdentifier: R.segue.sideMenuViewController.unwindToHome, sender: nil)
    }
  }
}
