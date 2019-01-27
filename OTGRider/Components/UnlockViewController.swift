//
//  UnlockViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 1/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit
import AVFoundation

class UnlockViewController: UIViewController {
  
    private var apiTask: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mapViewController = segue.destination as? MapViewController,
            let ride = sender as? Ride {
            mapViewController.ongoingRide = ride
        }
    }
    
    
    func unlockVehicle(unlockCode: String) {
        apiTask?.cancel()
        
        showLoading()
        
        apiTask = RideService.start(unlockCode: unlockCode,
                                     coordinate: currentLocation?.coordinate,
                                     completion: { [weak self] (ride, error) in
                                        
                                        DispatchQueue.main.async {
                                            self?.dismissLoading()
                                            
                                            guard error == nil else {
                                                logger.error(error?.localizedDescription)
                                                
                                                if error?.localizedDescription == "insufficient balance" {
                                                    self?.alertMessage("You account balance is not enough for a new ride",
                                                                       actionButtonTitle: "Top up balance",
                                                                       actionButtonTapped: {
                                                                        self?.navigateToAccount()
                                                    })
                                                } else {
                                                    self?.flashErrorMessage(error?.localizedDescription)
                                                }
                                                return
                                            }
                                            
                                            guard let ride = ride else {
                                                self?.flashErrorMessage(L10n.kOtherError)
                                                return
                                            }
                                            
                                            self?.navigateToMap(withRide: ride)
                                            
                                        }
        })
    }
    
    private func navigateToAccount() {
        if self.isKind(of: ScanUnlockViewController.self) {
            self.perform(segue: StoryboardSegue.Unlock.fromScanUnlockToAccount)
        }
        else {
            self.perform(segue: StoryboardSegue.Unlock.fromManualUnlockToAccount)
        }
    }
    
    private func navigateToMap(withRide ride: Ride) {
        if self.isKind(of: ScanUnlockViewController.self) {
            self.perform(segue: StoryboardSegue.Unlock.fromScanUnlockToMap, sender: ride)
        }
        else {
            self.perform(segue: StoryboardSegue.Unlock.fromManualUnlockToMap, sender: ride)
        }
    }
}

