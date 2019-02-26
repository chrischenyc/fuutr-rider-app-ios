//
//  HelpViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 17/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit
import ZendeskSDK

class HelpViewController: UIViewController {
  @IBOutlet weak var reportButton: UIButton!
  @IBOutlet weak var faqButton: UIButton!
  @IBOutlet weak var contactButton: UIButton!
  @IBOutlet weak var termsButton: UIButton!
  @IBOutlet weak var privacyButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyLightTheme()
    
    reportButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    reportButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
    faqButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    faqButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
    contactButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    contactButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
    termsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    termsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
    privacyButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    privacyButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
  }
  
  @IBAction func faq(_ sender: Any) {
    let viewController = ZDKHelpCenterUi.buildHelpCenterOverviewUi(withConfigs: [])
    self.navigationController?.pushViewController(viewController, animated: true)
  }
  
  @IBAction func contact(_ sender: Any) {
    let viewController = RequestUi.buildRequestUi()
    self.navigationController?.pushViewController(viewController, animated: true)
  }
  
  @IBAction func terms(_ sender: Any) {
    if let url = URL(string: config.env.termsURL), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
  
  @IBAction func privacy(_ sender: Any) {
    if let url = URL(string: config.env.privacyURL), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
}
