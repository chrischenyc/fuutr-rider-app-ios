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
    
    func userDidSignIn(authCoordinator: AuthCoordinator) {
        childDidFinish(authCoordinator)
        showHome(animated: true)
    }
    
    func userDidSignOut() {
        navigationController.popToRootViewController(animated: true)
        showGuestWelcome()
    }
}
