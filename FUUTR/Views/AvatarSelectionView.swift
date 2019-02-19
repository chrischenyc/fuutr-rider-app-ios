//
//  AvatarSelectionView.swift
//  FUUTR
//
//  Created by Chris Chen on 19/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit

@IBDesignable
class AvatarSelectionView: DesignableView {
  var onDismiss: (()->Void)?
  
  @IBOutlet weak var avtarsBackdropView: UIView!
  
  
  override var nibName: String {
    get {
      return "AvatarSelectionView"
    }
    set {}
  }
  
  override func commonInit() {
    super.commonInit()
    
    backgroundColor = UIColor.primaryDarkTranslucent
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss))
    self.addGestureRecognizer(tapRecognizer)
    let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismiss))
    swipeRecognizer.direction = .down
    self.addGestureRecognizer(swipeRecognizer)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    avtarsBackdropView.layoutCornerRadiusMask(corners: [.topLeft, .topRight])
  }
  
  @objc func dismiss() {
   onDismiss?()
  }
}
