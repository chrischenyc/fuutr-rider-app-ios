//
//  QRCode.swift
//  QRCode
//
//

import UIKit
import AVFoundation

open class QRCode: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    /// corner line width
    var lineWidth: CGFloat
    /// corner stroke color
    var strokeColor: UIColor
    /// the max count for detection
    var maxDetectedCount: Int
    /// current count for detection
    var currentDetectedCount: Int = 0
    /// auto remove sub layers when detection completed
    var autoRemoveSubLayers: Bool
    /// completion call back
    var completedCallBack: ((_ stringValue: String) -> ())?
    /// the scan rect, default is the bounds of the scan view, can modify it if need
    open var scanFrame: CGRect = CGRect.zero
    
    /// previewLayer
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        return layer
    }()
    
    /// drawLayer
    lazy var drawLayer = CALayer()
    /// session
    lazy var session = AVCaptureSession()
    /// input
    lazy var videoInput: AVCaptureDeviceInput? = {
        if let device = AVCaptureDevice.default(for: AVMediaType.video) {
            return try? AVCaptureDeviceInput(device: device)
        }
        return nil
    }()
    
    /// output
    lazy var dataOutput = AVCaptureMetadataOutput()
    
    ///  init function
    ///
    ///  - returns: the scanner object
    public override init() {
        self.lineWidth = 4
        self.strokeColor = UIColor.primaryRedColor
        self.maxDetectedCount = 20
        self.autoRemoveSubLayers = false
        
        super.init()
    }
    
    ///  init function
    ///
    ///  - parameter autoRemoveSubLayers: remove sub layers auto after detected code image
    ///  - parameter lineWidth:           line width, default is 4
    ///  - parameter strokeColor:         stroke color, default is Green
    ///  - parameter maxDetectedCount:    max detecte count, default is 20
    ///
    ///  - returns: the scanner object
    public init(autoRemoveSubLayers: Bool, lineWidth: CGFloat = 4, strokeColor: UIColor = UIColor.green, maxDetectedCount: Int = 20) {
        
        self.lineWidth = lineWidth
        self.strokeColor = strokeColor
        self.maxDetectedCount = maxDetectedCount
        self.autoRemoveSubLayers = autoRemoveSubLayers
    }
    
    deinit {
        if session.isRunning {
            session.stopRunning()
        }
        
        removeAllLayers()
    }
    
    
    
    // MARK: - Video Scan
    ///  prepare scan
    ///
    ///  - parameter view:       the scan view, the preview layer and the drawing layer will be insert into this view
    ///  - parameter completion: the completion call back
    open func prepareScan(_ view: UIView, completion:@escaping (_ stringValue: String)->()) {
        
        scanFrame = view.bounds
        
        completedCallBack = completion
        currentDetectedCount = 0
        
        setupSession()
        setupLayers(view)
    }
    
    /// start scan
    open func startScan() {
        if session.isRunning {
            print("the  capture session is running")
            
            return
        }
        session.startRunning()
    }
    
    /// stop scan
    open func stopScan() {
        if !session.isRunning {
            print("the capture session is not running")
            
            return
        }
        session.stopRunning()
    }
    
    func setupLayers(_ view: UIView) {
        drawLayer.frame = view.bounds
        view.layer.insertSublayer(drawLayer, at: 0)
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    func setupSession() {
        guard !session.isRunning else {
            print("the capture session is running")
            return
        }
        
        guard let videoInput = videoInput, session.canAddInput(videoInput) else {
            print("can not add input device")
            return
        }
        
        guard session.canAddOutput(dataOutput) else {
            print("can not add output device")
            return
        }
        
        session.addInput(videoInput)
        session.addOutput(dataOutput)
        
        dataOutput.metadataObjectTypes = dataOutput.availableMetadataObjectTypes;
        dataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    }
    
    
    open func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        clearDrawLayer()
        
        for dataObject in metadataObjects {
            
            if let codeObject = dataObject as? AVMetadataMachineReadableCodeObject,
                let obj = previewLayer.transformedMetadataObject(for: codeObject) as? AVMetadataMachineReadableCodeObject {
                
                if scanFrame.contains(obj.bounds) {
                    currentDetectedCount = currentDetectedCount + 1
                    if currentDetectedCount > maxDetectedCount {
                        session.stopRunning()
                        
                        completedCallBack!(codeObject.stringValue ?? "")
                        
                        if autoRemoveSubLayers {
                            removeAllLayers()
                        }
                    }
                    
                    // transform codeObject
                    drawCodeCorners(obj)
                }
            }
        }
    }
    
    open func removeAllLayers() {
        previewLayer.removeFromSuperlayer()
        drawLayer.removeFromSuperlayer()
    }
    
    func clearDrawLayer() {
        if drawLayer.sublayers == nil {
            return
        }
        
        for layer in drawLayer.sublayers! {
            layer.removeFromSuperlayer()
        }
    }
    
    func drawCodeCorners(_ codeObject: AVMetadataMachineReadableCodeObject) {
        if codeObject.corners.count == 0 {
            return
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = lineWidth
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.path = createPath(codeObject.corners as NSArray).cgPath
        
        drawLayer.addSublayer(shapeLayer)
    }
    
    func createPath(_ points: NSArray) -> UIBezierPath {
        let path = UIBezierPath()
        
        path.move(to: points[0] as! CGPoint)
        
        var index = 1
        while index < points.count {
            path.addLine(to: points[index] as! CGPoint)
            
            index = index + 1
        }
        path.close()
        
        return path
    }
    
    
}
