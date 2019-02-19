//
//  UIViewController+CameraPermission.swift
//  FUUTR
//
//  Created by Chris Chen on 18/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation
import AVFoundation

extension UIViewController {
  func checkScanPermissions(actionAfterFailure: (()->Void)? = nil) -> Bool {
    do {
      return try supportsMetadataObjectTypes()
    } catch let error as NSError {
      switch error.code {
      case -11852:
        alertMessage(title: nil,
                     message: "FUUTR needs camera access to scan the scooter's QR Code and take photos of your parked scooter.",
                     positiveActionButtonTitle: "Go to Settings",
                     positiveActionButtonTapped: {
                      if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                      }
        },
                     negativeActionButtonTitle: "Continue",
                     negativeActionButtonTapped: {
                      actionAfterFailure?()
        } )
        
      default:
        alertMessage(message: "Cannot open camera on this device.")
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
