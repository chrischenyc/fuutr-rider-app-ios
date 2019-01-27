extension UIViewController {
  func presentFullScreen(_ viewController: UIViewController) {
    viewController.providesPresentationContextTransitionStyle = true
    viewController.definesPresentationContext = true
    viewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
    
    self.present(viewController, animated: true, completion: nil)
  }
}
