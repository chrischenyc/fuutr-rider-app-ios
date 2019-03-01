//
//  IssueFormViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 17/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding

class IssueFormViewController: UIViewController {
  
  var issueType: IssueType?
  var ride: Ride?
  var vehicle: Vehicle?
  private var apiTask: URLSessionTask?
  
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var addPhotoButton: UIButton!
  @IBOutlet weak var submitButton: UIButton!
  @IBOutlet weak var submitButtonContainerView: UIView!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var imageStackView: UIStackView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyLightTheme()
    title = issueType?.title
    
    textView.layer.borderColor = UIColor.primaryGreyColor.cgColor
    textView.layer.borderWidth = 1.0
    textView.contentInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    textView.textColor = UIColor.primaryDarkColor
    textView.delegate = self
    
    addPhotoButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    KeyboardAvoiding.avoidingView = submitButtonContainerView
    textView.becomeFirstResponder()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let navigationController = segue.destination as? UINavigationController,
      let photoShootViewController = navigationController.topViewController as? PhotoShootViewController {
      photoShootViewController.action = .reportIssue
      photoShootViewController.title = "Photo about the issue"
    }
  }
  
  @IBAction func unwindToReportIssue(_ unwindSegue: UIStoryboardSegue) {
    let sourceViewController = unwindSegue.source
    
    if let photoShootViewController = sourceViewController as? PhotoShootViewController,
      let photo = photoShootViewController.photo {
      imageView.image = photo
      imageStackView.isHidden = false
      addPhotoButton.isHidden = true
    }
  }
  
  @IBAction func deletePhoto(_ sender: Any) {
    imageView.image = nil
    imageStackView.isHidden = true
    addPhotoButton.isHidden = false
  }
  
  @IBAction func onSubmit(_ sender: Any) {
    guard let issueType = issueType else { return }
    guard let description = textView.text, description.count > 0 else { return }
    guard let currentLocation = currentLocation else { return }
    
    apiTask?.cancel()
    
    showLoading()
    
    apiTask = IssueService.createIssue(type: issueType,
                                       description: description,
                                       coordinates: currentLocation.coordinate,
                                       vehicle: vehicle,
                                       ride: ride,
                                       image: imageView.image,
                                       completion: { [weak self] (error) in
                                        
                                        DispatchQueue.main.async {
                                          self?.dismissLoading()
                                          
                                          guard error == nil else {
                                            self?.alertError(error!)
                                            return
                                          }
                                          
                                          self?.alertMessage(title: "Issue Report Sent!",
                                                             message: "Thank you for helping make FUUTR better.",
                                                             image: R.image.imgSuccessCheck(),
                                                             hapticFeedbackType: .success,
                                                             positiveActionButtonTitle: "Done",
                                                             positiveActionButtonTapped: {
                                                              self?.performSegue(withIdentifier: R.segue.issueFormViewController.unwindToHome, sender: nil)
                                          })
                                        }
    })
  }
}

extension IssueFormViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    submitButton.isEnabled = textView.text.count > 0
  }
}
