//
//  UnlockByScanViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 1/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit
import AVFoundation

class UnlockByScanViewController: UIViewController {
    
    @IBOutlet weak var torchButton: UIButton!
    private var torchOn:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        torchButton.setTitle("Torch On", for: .normal)
    }
    
    
    @IBAction func unwindToUnlockByScan(_ unwindSegue: UIStoryboardSegue) {
        // let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    @IBAction func torchButtonTapped(_ sender: Any) {
        torchOn = !torchOn
        toggleTorch(on: torchOn)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        torchOn = false
        toggleTorch(on: torchOn)
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
}
