//
//  SideMenuViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 17/10/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import Kingfisher

class SideMenuViewController: UIViewController, Coordinatable {
    var cooridnator: Coordinator?
    
    
    @IBOutlet weak var greetingBackdropView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var rideHistoryButton: UIButton!
    @IBOutlet weak var walletButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var howToRideButton: UIButton!
    @IBOutlet weak var pointsButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let photo = currentUser?.photo, let avatarURL = URL(string: photo) {
            avatarImageView.kf.setImage(with: avatarURL)
        }
        
        greetingBackdropView.backgroundColor = UIColor.primaryRedColor
        if let displayName = currentUser?.displayName, displayName.count > 0 {
            greetingLabel.text = "G'day, \(displayName)!"
        }
        else {
            greetingLabel.text = "G'day!"
        }
        
        rideHistoryButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        rideHistoryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        
        walletButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        walletButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        
        accountButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        accountButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        
        howToRideButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        howToRideButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        
        pointsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        pointsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        
        helpButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        helpButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
    }
    
    override func viewDidLayoutSubviews() {
        avatarImageView.layoutCircularMask()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    // MARK: - user actions
    
    @IBAction func menuItemSelected(_ sender: Any) {
        if let button = sender as? UIButton {
            dismiss(animated: true) {
                guard let mainCoordinator = self.cooridnator as? MainCoordinator else { return }
                
                switch button {
                case self.rideHistoryButton:
                    mainCoordinator.showHistory()
                case self.walletButton:
                    mainCoordinator.showWallet()
                case self.accountButton:
                    mainCoordinator.showAccount()
                case self.howToRideButton:
                    mainCoordinator.showHowToRide()
                case self.helpButton:
                    mainCoordinator.showHelp()
                default:
                    break
                }
            }
            
        }
    }
}
