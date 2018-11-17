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
    
    @IBOutlet weak var torchButton: UIButton!
    
    private var torchOn: Bool = false
    private var apiTask: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        torchButton.setTitle("Torch On", for: .normal)
    }
    
    @IBAction func torchButtonTapped(_ sender: Any) {
        torchOn = !torchOn
        toggleTorch(on: torchOn)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // switch off torch and camear before leaving
        torchOn = false
        toggleTorch(on: torchOn)
        
        if let mapViewController = segue.destination as? MapViewController,
            let ride = sender as? Ride {
            mapViewController.ride = ride
        }
    }
    
    private func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else{ return }
        
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                
                if (on) {
                    device.torchMode = .on
                    torchButton.setTitle("Torch Off", for: .normal)
                    
                } else {
                    device.torchMode = .off
                    torchButton.setTitle("Torch On", for: .normal)
                }
                
                device.unlockForConfiguration()
            } catch {
                logger.error("Torch could not be used")
            }
        }
        else{
            logger.error("Torch is not available")
        }
    }
    
    
    func unlockScooter(vehicleCode: String) {
        apiTask?.cancel()
        
        showLoading()
        
        apiTask = RideService.unlock(vehicleCode: vehicleCode, completion: { [weak self] (ride, error) in
            
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

