//
//  UnlockViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 1/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import AVFoundation

protocol UnlockDelegate: AnyObject {
  func vehicleUnlocked(with ride: Ride)
}

class UnlockViewController: UIViewController {
  
  private var apiTask: URLSessionTask?
  weak var delegate: UnlockDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func unlockVehicle(unlockCode: String,
                     onBalanceInsufficientError: (() -> Void)? = nil,
                     onGeneralError: ((Error) -> Void)? = nil) {
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
                                                            // TODO: need to indicate AccountViewController, after successful top up, return back to unlock screen
                                                            onBalanceInsufficientError?()
                                        })
                                      } else {
                                        onGeneralError?(error)
                                      }
                                      return
                                    }
                                    guard let ride = ride else {
                                      self?.flashErrorMessage(R.string.localizable.kOtherError())
                                      return
                                    }
                                    self?.dismiss(animated: true, completion: {
                                      self?.delegate?.vehicleUnlocked(with: ride)
                                    })
                                  }
    })
  }
}

