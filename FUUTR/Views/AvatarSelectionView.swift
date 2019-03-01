//
//  AvatarSelectionView.swift
//  FUUTR
//
//  Created by Chris Chen on 19/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit

enum PresetAvatar: Int {
  case boy1, boy2, girl1, girl2, man1, man2, woman1, woman2
  
  var image:UIImage {
    switch self {
    case .boy1:
      return R.image.boy1()!
    case .boy2:
      return R.image.boy2()!
    case .girl1:
      return R.image.girl1()!
    case .girl2:
      return R.image.girl2()!
    case .man1:
      return R.image.man1()!
    case .man2:
      return R.image.man2()!
    case .woman1:
      return R.image.woman1()!
    case .woman2:
      return R.image.woman2()!
    }
  }
}

@IBDesignable
class AvatarSelectionView: DesignableView {
  var onDismiss: (()->Void)?
  var onCamera: (()->Void)?
  var onSelectPresetAvatar: ((UIImage)->Void)?
  
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
    
    avtarsBackdropView.layoutCornerRadiusMask(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
  }
  
  @objc func dismiss() {
   onDismiss?()
  }
  
  @IBAction func avatarSelected(_ sender: Any) {
    if let button = sender as? UIButton,
      let presetAvatar = PresetAvatar(rawValue: button.tag) {
      onSelectPresetAvatar?(presetAvatar.image)
    }
  }
  
  @IBAction func cancel(_ sender: Any) {
    dismiss()
  }
  
  @IBAction func camera(_ sender: Any) {
    onCamera?()
  }
}
