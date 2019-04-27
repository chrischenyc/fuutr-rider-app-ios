//
//  AuthCoordinator.swift
//  FUUTR
//
//  Created by Chris Chen on 27/4/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation

class AuthCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        guard let welcomeViewController = R.storyboard.welcome().instantiateInitialViewController() as? WelcomeViewController else {
            fatalError("Cannot instantiate WelcomeViewController!")
        }
        
        welcomeViewController.cooridnator = self
        
        navigationController.pushViewController(welcomeViewController, animated: false)
    }
}
