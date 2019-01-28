extension UIViewController {
  func presentFullScreen(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
    viewController.providesPresentationContextTransitionStyle = true
    viewController.definesPresentationContext = true
    viewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
    
    self.present(viewController, animated: true, completion: completion)
  }
}
