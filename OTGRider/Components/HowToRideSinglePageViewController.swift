//
//  HowToRideSinglePageViewController.swift
//  FUUTR
//
//  Copyright © 2019 FUUTR. All rights reserved.
//

import SwiftyUserDefaults

protocol HowToRideSinglePageDelegate {
  func showNextPage()
}

class HowToRideSinglePageViewController: UIViewController {
  
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var skipButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var rideButton: UIButton!
  @IBOutlet weak var nextButton: UIButton!
  
  var delegate: HowToRideSinglePageDelegate?
  
  var descriptionText: String?
  var imageName: String?
  var image: UIImage?
  var isLastPage: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    contentView.backgroundColor = UIColor.primaryRedColor
    descriptionLabel.text = descriptionText
    imageView.image = image
    
    if isLastPage {
      rideButton.isHidden = false
      rideButton.setTitleColor(UIColor.primaryRedColor, for: .normal)
      rideButton.layer.cornerRadius = 5
      nextButton.isHidden = true
    }
    
    nextButton.addTarget(self, action: #selector(showNextPage), for: .touchUpInside)
    skipButton.addTarget(self, action: #selector(skip), for: .touchUpInside)
    rideButton.addTarget(self, action: #selector(ride), for: .touchUpInside)
  }
  
  @objc func showNextPage() {
    delegate?.showNextPage()
  }
  
  @objc func skip() {
    DispatchQueue.main.async {
      Defaults[.userTrainedHowToRide] = true
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  @objc func ride() {
    self.dismiss(animated: true, completion: nil)
  }
}
