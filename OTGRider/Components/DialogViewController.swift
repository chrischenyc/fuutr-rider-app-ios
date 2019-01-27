//
//  DialogViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 27/1/19.
//  Copyright © 2019 OTGRide. All rights reserved.
//

import UIKit

class DialogViewController: UIViewController {
    
    var messageTitle: String?
    var message: String?
    var positiveActionButtonTitle: String?
    var positiveActionButtonTapped: (()->Void)?
    var negativeActionButtonTitle: String?
    var negativeActionButtonTapped: (()->Void)?
    
    init(title: String?,
        message: String?,
        positiveActionButtonTitle: String,
        positiveActionButtonTapped: (()->Void),
        negativeActionButtonTitle: String? = nil,
        negativeActionButtonTapped: (()->Void)? = nil) {
        
        self.messageTitle = title
        self.message = message
        self.positiveActionButtonTitle = positiveActionButtonTitle
        self.positiveActionButtonTapped = positiveActionButtonTapped
        self.negativeActionButtonTitle = negativeActionButtonTitle
        self.negativeActionButtonTapped = negativeActionButtonTapped
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var positiveButton: UIButton!
    @IBOutlet weak var negativeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.textColor = UIColor.primaryDarkColor
        messageLabel.textColor = UIColor.primaryDarkColor
        
        positiveButton.primaryRed()
        negativeButton.primaryRedBasic()
    }
}
