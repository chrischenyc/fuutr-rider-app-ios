//
//  MainCoordinator.swift
//  FUUTR
//
//  Created by Chris Chen on 27/4/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

// main coordinator to take control over the app as soon as it launches
class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        var viewController: UIViewController?
        if Defaults[.userSignedIn] {
            viewController = R.storyboard.main().instantiateInitialViewController()
        } else {
            viewController = R.storyboard.welcome().instantiateInitialViewController()
        }
        
        guard viewController != nil else {
            fatalError("Cannot instantiate the initial view controller")
        }
        
        if var coordinatable = viewController as? Coordinatable {
            coordinatable.cooridnator = self
        }
        
        navigationController.pushViewController(viewController!, animated: false)
    }
}
