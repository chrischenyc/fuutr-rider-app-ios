//
//  ScanUnlockViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 15/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import Foundation
import AVFoundation

class ScanUnlockViewController: UnlockViewController {
  
  private let scanner = QRCode()
  
  @IBOutlet weak var placeHolderView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyDarkTheme()
    view.backgroundColor = UIColor.primaryDarkColor
    scanner.prepareScan(view) { (stringValue) -> () in
      self.handleScanResult(stringValue)
    }
    scanner.scanFrame = view.bounds
    placeHolderView.layer.borderColor = UIColor.white.cgColor
    placeHolderView.layer.borderWidth = 2
  }
  
  
  override func viewDidAppear(_ animated: Bool) {
    guard checkScanPermissions() else { return }
    
    scanner.startScan()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    scanner.stopScan()
  }
  
  @IBAction func unwindToScanUnlock(_ segue: UIStoryboardSegue) {
    
  }
  
  private func handleScanResult(_ result: String) {
    unlockVehicle(unlockCode: result, onGeneralError: { [weak self] error in
      self?.alertError(error, actionButtonTitle: "OK", actionButtonTapped: {
        self?.scanner.clearDrawLayer()
        self?.scanner.startScan()
      })
    })
  }
}

// MARK: - camera permission
extension ScanUnlockViewController {
  
  private func checkScanPermissions() -> Bool {
    do {
      return try supportsMetadataObjectTypes()
    } catch let error as NSError {
      switch error.code {
      case -11852:
        alertMessage(title: nil,
                     message: "This app is not authorized to use Back Camera. Please grant permission in Settings",
                     positiveActionButtonTitle: "Go to Settings",
                     positiveActionButtonTapped: {
                      if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                      }
        })
        
      default:
        alertMessage(message: "Current device doesn't support QR code scanning, please try manually inputing the code.")
      }
      
      return false
    }
  }
  
  private func supportsMetadataObjectTypes(_ metadataTypes: [AVMetadataObject.ObjectType]? = nil) throws -> Bool {
    guard let captureDevice = AVCaptureDevice.default(for: .video) else {
      logger.error("unsupported device")
      return false
    }
    
    let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
    let output      = AVCaptureMetadataOutput()
    let session     = AVCaptureSession()
    
    session.addInput(deviceInput)
    session.addOutput(output)
    
    var metadataObjectTypes = metadataTypes
    
    if metadataObjectTypes == nil || metadataObjectTypes?.count == 0 {
      // Check the QRCode metadata object type by default
      metadataObjectTypes = [.qr]
    }
    
    for metadataObjectType in metadataObjectTypes! {
      if !output.availableMetadataObjectTypes.contains { $0 == metadataObjectType } {
        return false
      }
    }
    
    return true
  }
  
}
