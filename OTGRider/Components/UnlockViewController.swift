//
//  UnlockViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 1/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import AVFoundation

class UnlockViewController: UIViewController {
  
  private var apiTask: URLSessionTask?
  var unlockCode: String?
  var ride: Ride? // has value after successfully unlocked, will be assessed by MapViewController during segue unwind
  
  func unlockVehicle(unlockCode: String, onGeneralError: ((Error) -> Void)? = nil) {
    self.unlockCode = unlockCode
    apiTask?.cancel()
    
    showLoading()
    
    apiTask = RideService.start(unlockCode: unlockCode,
                                completion: { [weak self] (ride, error) in
                                  DispatchQueue.main.async {
                                    self?.dismissLoading()
                                    
                                    if let error = error {
                                      logger.error(error.localizedDescription)
                                      
                                      if error.localizedDescription == "insufficient balance" {
                                        self?.alertMessage(title: nil,
                                                           message: "You account balance is not enough for a new ride",
                                                           positiveActionButtonTitle: "Top up balance",
                                                           positiveActionButtonTapped: {
                                                            // TODO: segue to AccountViewController for topup, after successful top up, return back to re-try unlock
                                        })
                                      } else {
                                        onGeneralError?(error)
                                      }
                                      return
                                    }
                                    
                                    guard let ride = ride else {
                                      self?.alertMessage(message: R.string.localizable.kOtherError())
                                      return
                                    }
                                    
                                    self?.ride = ride
                                    
                                    if let scanUnlock = self?.isKind(of: ScanUnlockViewController.self) {
                                      if scanUnlock {
                                        self?.performSegue(withIdentifier: R.segue.scanUnlockViewController.unwindToHome.identifier, sender: ride)
                                      }
                                      else {
                                        self?.performSegue(withIdentifier: R.segue.manualUnlockViewController.unwindToHome.identifier, sender: ride)
                                      }
                                    }
                                    
                                  }
    })
  }
}

