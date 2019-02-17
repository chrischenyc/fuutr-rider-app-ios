//
//  HelpViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 17/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
  @IBOutlet weak var reportButton: UIButton!
  @IBOutlet weak var faqButton: UIButton!
  @IBOutlet weak var contactButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyLightTheme()
    
    reportButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    reportButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
    faqButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    faqButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
    contactButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    contactButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
  }
  
  @IBAction func faq(_ sender: Any) {
    if let url = URL(string: config.env.helpURL), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
  
  @IBAction func contact(_ sender: Any) {
    if let url = URL(string: config.env.contactURL), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
}
