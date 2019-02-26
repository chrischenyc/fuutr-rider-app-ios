//
//  NZLandTransportActViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 26/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit

class NZLandTransportActViewController: UIViewController {
  @IBOutlet weak var descriptionTextView: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.primaryRedColor
    descriptionTextView.delegate = self
    
    let termsLinkText = "Rider Agreement"
    let act2004LinkText = "Land Transport Act 2004"
    let contentText = "By riding one of our vehicles, you are accepting and adhering to our \(termsLinkText) and following guidelines set in the \(act2004LinkText)"
    
    let attributedString = NSMutableAttributedString(string: contentText)
    
    if let termsRange = contentText.range(of: termsLinkText) {
      attributedString.addAttribute(.link, value: "https://www.fuutr.co/terms", range: NSRange(termsRange, in: contentText))
    }
    
    if let act2004Range = contentText.range(of: act2004LinkText) {
      attributedString.addAttribute(.link, value: "http://www.legislation.govt.nz/regulation/public/2004/0427/67.0/DLM302188.html", range: NSRange(act2004Range, in: contentText))
    }
    
    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.primaryWhiteColor, range: NSRange(location: 0, length: contentText.count))
    attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: contentText.count))
    
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: contentText.count))
    
    descriptionTextView.attributedText = attributedString
    descriptionTextView.linkTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.primaryWhiteColor,
      NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
    ]
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  @IBAction func confirmTapped(_ sender: Any) {
    // TODO: record user defaults
    performSegue(withIdentifier: R.segue.nzLandTransportActViewController.showHowToRide, sender: nil)
  }
}


extension NZLandTransportActViewController: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    UIApplication.shared.open(URL, options: [:])
    return false
  }
}
