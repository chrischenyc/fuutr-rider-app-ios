//
//  ScanUnlockViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 15/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation
import AVFoundation

class ScanUnlockViewController: UnlockViewController {
    
    private let scanner = QRCode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanner.prepareScan(view) { (stringValue) -> () in
            self.handleScanResult(stringValue)
        }
        scanner.scanFrame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard checkScanPermissions() else { return }
        
        scanner.startScan()
    }
    
    @IBAction func unwindToUnlockByScan(_ unwindSegue: UIStoryboardSegue) {
        // let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        scanner.stopScan()
    }
    
    private func handleScanResult(_ result: String) {
        logger.debug(result)
        
        unlockVehicle(unlockCode: result)
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
                alertMessage("This app is not authorized to use Back Camera. Please grant permission in Settings", actionButtonTitle: "Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                    }
                }
                
            default:
                flashErrorMessage("Current device doesn't support QR code scanning, please try manually inputing the code.")
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
