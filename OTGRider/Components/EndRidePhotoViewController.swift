//
//  EndRidePhotoViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 27/1/19.
//  Copyright © 2019 OTGRide. All rights reserved.
//

import UIKit
import FastttCamera

class EndRidePhotoViewController: UIViewController {
  
  @IBOutlet weak var cameraView: UIView!
  @IBOutlet weak var shootButton: UIButton!
  
  let fastCamera = FastttCamera()
  var ride: Ride!
  var photo: UIImage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    
    fastCamera.delegate = self
    
    loadCameraView()
  }
  
  private func setupUI() {
    shootButton.backgroundColor = UIColor.primaryRedColor
    shootButton.layoutCornerRadiusMask(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadius: shootButton.frame.size.width/2)
  }
  
  private func loadCameraView() {
    fastttAddChildViewController(fastCamera)
    fastCamera.view.frame = self.cameraView.frame
  }
  
  @IBAction func shootTapped(_ sender: Any) {
  }
  
}

extension EndRidePhotoViewController: FastttCameraDelegate {
  
}
