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
  
  func unlockVehicle(unlockCode: String,
                     onSuccess: ((Ride) -> Void)? = nil,
                     onBalanceInsufficientError: (() -> Void)? = nil,
                     onGeneralError: ((Error) -> Void)? = nil) {
    apiTask?.cancel()
    
    showLoading()
    
    apiTask = RideService.start(unlockCode: unlockCode,
                                 coordinate: currentLocation?.coordinate,
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
           self?.flashErrorMessage(L10n.kOtherError)
           return
         }
         onSuccess?(ride)
       }
    })
  }
}

