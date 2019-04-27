//
//  MainCoordinator.swift
//  FUUTR
//
//  Created by Chris Chen on 27/4/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import SideMenu

// main coordinator to take control over the app as soon as it launches
class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        if Defaults[.userSignedIn] {
            showHome(animated: false)
        } else {
            showGuestWelcome()
        }
    }
}

extension MainCoordinator {
    func showHome(animated: Bool) {
        guard let mainViewController = R.storyboard.main().instantiateInitialViewController() as? MainViewController else {
            fatalError("Cannot instantiate the initial view controller")
        }
        
        mainViewController.cooridnator = self
        navigationController.pushViewController(mainViewController, animated: animated)
    }
    
    func showGuestWelcome() {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.parentCoordinator = self
        childCoordinators.append(authCoordinator)
        authCoordinator.start()
    }
    
    func showSideMenu() {
        guard let sideMenuNavigationController = R.storyboard.sideMenu().instantiateInitialViewController() as? UISideMenuNavigationController,
        let sideMenuViewController = sideMenuNavigationController.topViewController as? SideMenuViewController
        else {
            fatalError("Cannot instantiate the side menu view controller")
        }
        
        sideMenuViewController.cooridnator = self
        navigationController.present(sideMenuNavigationController, animated: true, completion: nil)
    }
    
    func showAccount() {
        guard let navigationController = R.storyboard.account().instantiateInitialViewController() as? UINavigationController,
        let accountViewController = navigationController.topViewController as? AccountViewController else {
            fatalError("Cannot instantiate the account view controller")
        }
        
        accountViewController.cooridnator = self
        self.navigationController.present(navigationController, animated: true, completion: nil)
    }
    
    func showHistory() {
        guard let navigationController = R.storyboard.history().instantiateInitialViewController() as? UINavigationController,
            let historyViewController = navigationController.topViewController as? HistoryRidesTableViewController else {
                fatalError("Cannot instantiate the history view controller")
        }
        
        historyViewController.cooridnator = self
        self.navigationController.present(navigationController, animated: true, completion: nil)
    }
    
    func showWallet() {
        guard let navigationController = R.storyboard.wallet().instantiateInitialViewController() as? UINavigationController,
            let walletViewController = navigationController.topViewController as? WalletViewController else {
                fatalError("Cannot instantiate the wallet view controller")
        }
        
        walletViewController.cooridnator = self
        self.navigationController.present(navigationController, animated: true, completion: nil)
    }
    
    func showHelp() {
        guard let navigationController = R.storyboard.help().instantiateInitialViewController() as? UINavigationController,
            let helpViewController = navigationController.topViewController as? HelpViewController else {
                fatalError("Cannot instantiate the help view controller")
        }
        
        helpViewController.cooridnator = self
        self.navigationController.present(navigationController, animated: true, completion: nil)
    }
    
    func showHowToRide() {
        guard let howToRideViewController = R.storyboard.howToRide().instantiateInitialViewController() as? HowToRideViewController else {
                fatalError("Cannot instantiate the how to ride view controller")
        }
        
        howToRideViewController.cooridnator = self
        self.navigationController.present(howToRideViewController, animated: true, completion: nil)
    }
    
    func userDidSignIn(authCoordinator: AuthCoordinator) {
        childDidFinish(authCoordinator)
        showHome(animated: true)
    }
    
    func userDidSignOut() {
        navigationController.popToRootViewController(animated: true)
        showGuestWelcome()
    }
}
