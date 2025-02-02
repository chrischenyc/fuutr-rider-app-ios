//
//  Coordinator.swift
//  FUUTR
//
//  Created by Chris Chen on 27/4/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation

// all coordinators need to conform to this protocol and need to be a class
protocol Coordinator: AnyObject {
    // use subcoordinators to carve off part of the navigation of the app
    var childCoordinators: [Coordinator] { get set }
    
    // used to present view controllers, even the navigation bar isn't shown at the top
    var navigationController: UINavigationController { get set }
    
    // create a coordinator fully and activate it only when we’re ready
    func start()
    
    func childDidFinish(_ child: Coordinator)
}

// default implementation of the optional protocol method
extension Coordinator {
    func childDidFinish(_ child: Coordinator) {
        for (index, childCoordinator) in childCoordinators.enumerated() {
            if childCoordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}
