//
//  PhotoShootViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 27/1/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit
import FastttCamera

enum PhotoShootViewControllerAction {
  case scooterParked, userAvatar, reportIssue
}

class PhotoShootViewController: UIViewController {
  
  @IBOutlet weak var cameraView: UIView!
  @IBOutlet weak var previewImageView: UIImageView!
  @IBOutlet weak var shootButton: UIButton!
  @IBOutlet weak var shootView: UIView!
  @IBOutlet weak var sendView: UIView!
  @IBOutlet weak var takeAnotherButton: UIButton!
  @IBOutlet weak var sendButton: UIButton!
  
  let fastCamera = FastttCamera()
  var photo: UIImage?
  var submitButtonTitle: String = "Next"
  var action: PhotoShootViewControllerAction?
  var enableFrontCamera: Bool = false
  var dismissable: Bool = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    shootButton.backgroundColor = UIColor.primaryRedColor
    if dismissable {
      navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(image: R.image.icCloseDarkGray16(), style: .plain, target: self, action: #selector(closeTapped))
    }
    navigationController?.navigationBar.applyLightTheme()
    
    fastCamera.delegate = self
    
    switchToCamera()
    
    if let action = action, action == .scooterParked {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.alertMessage(title: "Take a picture of the parked scooter",
                              message: "To finish your ride, you need to send FUUTR a picture of the parked scooter",
                              image: R.image.imgParkedScooterPhoto(),
                              hapticFeedbackType: .warning)
        }
    }
  }
  
  override func viewDidLayoutSubviews() {
    fastCamera.view.frame = self.cameraView.frame
    
    shootView.layoutCornerRadiusMask(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
    sendView.layoutCornerRadiusMask(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
    shootButton.layoutCircularMask()
    sendButton.setTitle(submitButtonTitle, for: .normal)
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
  
  @objc func closeTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func shootTapped(_ sender: Any) {
    // on Simulator, skip to next
    if Platform.isSimulator {
      self.photo = R.image.launch()
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
    guard let photo = photo else { return }
    
    if let action = action {
      switch action {
      case .scooterParked:
        performSegue(withIdentifier: R.segue.photoShootViewController.unwindToHome, sender: photo)
      case .userAvatar:
        performSegue(withIdentifier: R.segue.photoShootViewController.unwindToSettings, sender: photo)
      case .reportIssue:
        performSegue(withIdentifier: R.segue.photoShootViewController.unwindToReportIssue, sender: photo)
      }
    }
  }
  
}

extension PhotoShootViewController: FastttCameraDelegate {
  func cameraController(_ cameraController: FastttCameraInterface!, didFinishNormalizing capturedImage: FastttCapturedImage!) {
    self.photo = capturedImage.scaledImage
    self.previewImageView.image = self.photo
    self.switchToPreview()
  }
}
