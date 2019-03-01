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
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let navigationController = segue.destination as? UINavigationController,
      let topUpViewController = navigationController.topViewController as? TopUpViewController {
      topUpViewController.insufficientFund = true
      topUpViewController.delegate = self
    }
  }
  
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
                                      
                                      if let appError = error as? AppError, appError == .lowBalance {
                                        if let scanUnlock = self?.isKind(of: ScanUnlockViewController.self) {
                                          if scanUnlock {
                                            self?.performSegue(withIdentifier: R.segue.scanUnlockViewController.showTopUp.identifier, sender: nil)
                                          }
                                          else {
                                            self?.performSegue(withIdentifier: R.segue.manualUnlockViewController.showTopUp.identifier, sender: nil)
                                          }
                                        }
                                        
                                      } else {
                                        if let onGeneralError = onGeneralError {
                                          onGeneralError(error)
                                        }
                                        else {
                                          self?.alertError(error)
                                        }
                                        
                                      }
                                      return
                                    }
                                    
                                    guard let ride = ride else { return }
                                    
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

extension UnlockViewController: TopUpViewControllerDelegate {
  func didTopUp(topUpViewController: UIViewController) {
    topUpViewController.dismiss(animated: true) { [weak self] in
      guard let unlockCode = self?.unlockCode else { return }
      
      self?.unlockVehicle(unlockCode: unlockCode)
    }
  }
}
