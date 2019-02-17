//
//  IssueFormViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 17/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit

class IssueFormViewController: UIViewController {
  
  var issueType: IssueType?
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var addPhotosButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyLightTheme()
    title = issueType?.title
    
    textView.layer.borderColor = UIColor.primaryGreyColor.cgColor
    textView.layer.borderWidth = 1.0
    textView.contentInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    textView.textColor = UIColor.primaryDarkColor
    
    addPhotosButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
  }
  
  override func viewDidLayoutSubviews() {
    textView.layoutCornerRadiusMask(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
  }
}
