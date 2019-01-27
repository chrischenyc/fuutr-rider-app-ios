//
//  DialogViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 27/1/19.
//  Copyright © 2019 OTGRide. All rights reserved.
//

import UIKit

class DialogViewController: UIViewController {
    
    var image: UIImage?
    var messageTitle: String?
    var message: String?
    var positiveActionButtonTitle: String = "OK"
    var positiveActionButtonTapped: (()->Void)?
    var negativeActionButtonTitle: String?
    var negativeActionButtonTapped: (()->Void)?
    
    init(title: String?,
        message: String?,
        image: UIImage? = nil,
        positiveActionButtonTitle: String?,
        positiveActionButtonTapped: (()->Void)?,
        negativeActionButtonTitle: String? = nil,
        negativeActionButtonTapped: (()->Void)? = nil) {
        
        self.messageTitle = title
        self.message = message
        self.image = image
        if let positiveActionButtonTitle = positiveActionButtonTitle {
            self.positiveActionButtonTitle = positiveActionButtonTitle
        }
        self.positiveActionButtonTapped = positiveActionButtonTapped
        self.negativeActionButtonTitle = negativeActionButtonTitle
        self.negativeActionButtonTapped = negativeActionButtonTapped
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var positiveButton: UIButton!
    @IBOutlet weak var negativeButton: UIButton!
    @IBOutlet weak var negativeButtonContainer: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        // only leave controls with content
        
        if let image = image {
            imageView.image = image
            imageViewHeightConstraint.constant = image.size.height
        } else {
            stackView.removeArrangedSubview(imageView)
            imageView.removeFromSuperview()
        }
        
        if let messageTitle = messageTitle, messageTitle.count > 0 {
            titleLabel.textColor = UIColor.primaryDarkColor
            titleLabel.text = messageTitle
        }
        else {
            stackView.removeArrangedSubview(titleLabel)
            titleLabel.removeFromSuperview()
        }
        
        if let message = message, message.count > 0 {
            messageLabel.textColor = UIColor.primaryDarkColor
            messageLabel.text = message
        } else {
            stackView.removeArrangedSubview(messageLabel)
            messageLabel.removeFromSuperview()
        }
        
        positiveButton.primaryRed()
        positiveButton.setTitle(positiveActionButtonTitle, for: .normal)
        positiveButton.addTarget(self, action: #selector(positiveTapped), for: .touchUpInside)
        
        if let negativeActionButtonTitle = negativeActionButtonTitle, negativeActionButtonTitle.count > 0 {
            negativeButton.primaryDarkBasic()
            negativeButton.setTitle(negativeActionButtonTitle, for: .normal)
            negativeButton.addTarget(self, action: #selector(negativeTapped), for: .touchUpInside)
        }
        else {
            stackView.removeArrangedSubview(negativeButton)
            negativeButton.removeFromSuperview()
        }
        
    }
    
    @objc private func positiveTapped() {
        positiveActionButtonTapped?()
    }
    
    @objc private func negativeTapped() {
        negativeActionButtonTapped?()
    }
}
