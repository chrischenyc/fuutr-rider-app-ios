//
//  RideParkedPhotoViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 27/1/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit
import FastttCamera

class RideParkedPhotoViewController: UIViewController {
  
  @IBOutlet weak var cameraView: UIView!
  @IBOutlet weak var previewImageView: UIImageView!
  @IBOutlet weak var shootButton: UIButton!
  @IBOutlet weak var shootView: UIView!
  @IBOutlet weak var sendView: UIView!
  @IBOutlet weak var takeAnotherButton: UIButton!
  @IBOutlet weak var sendButton: UIButton!
  
  let fastCamera = FastttCamera()
  var ride: Ride!
  var photo: UIImage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    
    fastCamera.delegate = self
    
    switchToCamera()
  }
  
  override func viewDidLayoutSubviews() {
    shootView.layoutCornerRadiusMask(corners: [.topRight, .topLeft])
    sendView.layoutCornerRadiusMask(corners: [.topRight, .topLeft])
    shootButton.layoutCornerRadiusMask(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadius: shootButton.frame.size.width/2)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let navigationController = segue.destination as? UINavigationController,
      let rideFinishedViewController = navigationController.topViewController as? RideFinishedViewController,
      let ride = sender as? Ride {
      rideFinishedViewController.ride = ride
    }
  }
  
  private func setupUI() {
    shootButton.backgroundColor = UIColor.primaryRedColor
  }
  
  private func switchToCamera() {
    sendView.isHidden = true
    previewImageView.isHidden = true
    
    // bypass camera setup on Simulator
    if !Platform.isSimulator {
      fastttAddChildViewController(fastCamera)
      fastCamera.view.frame = self.cameraView.frame
    }
    
    view.bringSubviewToFront(shootView)
  }
  
  private func switchToPreview() {
    sendView.isHidden = false
    previewImageView.isHidden = false
    
    fastttRemoveChildViewController(fastCamera)
    
    view.bringSubviewToFront(sendView)
  }
  
  @IBAction func shootTapped(_ sender: Any) {
    // on Simulator, skip to next
    if Platform.isSimulator {
      self.photo = R.image.howToRide1()
      self.previewImageView.image = self.photo
      switchToPreview()
      
      return
    }
    
    // UI API called on a background thread: https://github.com/IFTTT/FastttCamera/issues/80
    self.fastCamera.takePicture()
  }
  
  @IBAction func takeAnotherTapped(_ sender: Any) {
    switchToCamera()
  }
  
  
  @IBAction func sendTapped(_ sender: Any) {
    // TODO: invoke send photo API
    
    performSegue(withIdentifier: R.segue.rideParkedPhotoViewController.showRideSummary, sender: ride)
  }
  
}

extension RideParkedPhotoViewController: FastttCameraDelegate {
  func cameraController(_ cameraController: FastttCameraInterface!, didFinishNormalizing capturedImage: FastttCapturedImage!) {
    self.photo = capturedImage.scaledImage
    self.previewImageView.image = self.photo
    self.switchToPreview()
  }
}
