//
//  ScanUnlockViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 15/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation
import AVFoundation

class ScanUnlockViewController: UnlockViewController {
  
  private let scanner = QRCode()
  private var torchOn = false
  
  @IBOutlet weak var placeHolderView: UIView!
  @IBOutlet weak var torchButton: UIButton!
  @IBOutlet weak var qrCodeImageHeightContraint: NSLayoutConstraint!
  
  // MARK: - lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyDarkTheme()
    view.backgroundColor = UIColor.primaryDarkColor
    
    scanner.prepareScan(view) { [weak self] (string) -> () in
      self?.unlockVehicle(unlockCode: string, onGeneralError: { error in
        self?.alertError(error, actionButtonTitle: "OK", actionButtonTapped: {
          self?.scanner.clearDrawLayer()
          self?.scanner.startScan()
        })
      })
    }
    scanner.scanFrame = view.bounds
    
    placeHolderView.layer.borderColor = UIColor.white.cgColor
    placeHolderView.layer.borderWidth = 2
    
    torchButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    
    // adjust auto-layout to fit everything in iPhone 5 screen
    if UIScreen.main.bounds.height <= 568 {
      qrCodeImageHeightContraint.constant = 80
    }
  }
  
  
  override func viewDidAppear(_ animated: Bool) {
    guard checkScanPermissions() else { return }
    
    scanner.startScan()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    scanner.stopScan()
  }
  
  // MARK: - user actions
  @IBAction func unwindToScanUnlock(_ segue: UIStoryboardSegue) {
  }
  
  @IBAction func toggleTorch(_ sender: Any) {
    guard let device = AVCaptureDevice.default(for: AVMediaType.video) else{ return }
    
    if (device.hasTorch) {
      do {
        try device.lockForConfiguration()
        
        torchOn = !torchOn
        if (torchOn) {
          device.torchMode = .on
          torchButton.setImage(R.image.icTorchOffWhite(), for: .normal)
          
        } else {
          device.torchMode = .off
          torchButton.setImage(R.image.icTorchOnWhite(), for: .normal)
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

