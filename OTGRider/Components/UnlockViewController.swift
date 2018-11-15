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
    
    enum UnlockType {
        case scan
        case input
    }
    
    @IBOutlet weak var torchButton: UIButton!
    @IBOutlet weak var codeReaderView: UIView!
    
    private var torchOn: Bool = false
    var type: UnlockType = .scan
    private let scanner = QRCode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        torchButton.setTitle("Torch On", for: .normal)
        
        scanner.prepareScan(codeReaderView) { (stringValue) -> () in
            self.handleScanResult(stringValue)
        }
        scanner.scanFrame = codeReaderView.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard checkScanPermissions() else { return }
        
        scanner.startScan()
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
        // switch off torch and camear before leaving
        torchOn = false
        toggleTorch(on: torchOn)
        
        //        codeReader.stopScanning()
        
        if segue.identifier == StoryboardSegue.Unlock.fromScanToInput.rawValue,
            let inputUnlockViewController = segue.destination as? UnlockViewController {
            inputUnlockViewController.type = .input
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
    
    private func handleScanResult(_ result: String) {
        logger.debug(result)
        
        // TODO: parse vehicle code and IoT code
        let vehicleCode = "1234"
        let iotCode = "5678"
        
        // TODO: call api
    }
}

// MARK: - camera permission
extension UnlockViewController {
    
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
            throw NSError(domain: "com.otgride", code: -1001, userInfo: nil)
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
