class HowToRideViewController: UIPageViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dataSource = self
    
    if let firstViewController = pages.first {
      setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
    }
  }
  
  private(set) lazy var pages: [UIViewController] = {
    let page1 = getViewController(withDescription: "Push the vehicle twice with your foot to get started.")
    
    let page2 = getViewController(withDescription: "Push down the right hand throttle to use E-Motor.")
    
    let page3 = getViewController(withDescription: "Always keep both feet on the deck of the vehicle while riding.")
    
    let page4 = getViewController(withDescription: "Always use shared paths or bike lanes and always ride to the left.")
    
    let page5 = getViewController(withDescription: "DO NOT ride OTG Ride vehicles on the sidewalk. Follow all road rules.")
    
    let page6 = getViewController(withDescription: "Park your vehicle in a dedicated OTG Ride Parking Hub or close to the curb, out of the way of pedestrians. Your parking compliance is strictly monitored via a photo at the end of ride.")
    
    return [page1, page2, page3, page4, page5, page6]
  }()
  
  fileprivate func getViewController(withDescription: String) -> HowToRideSinglePageViewController
  {
    let viewController = UIStoryboard(name: "HowToRide", bundle: nil).instantiateViewController(withIdentifier: "HowToRideSinglePageViewController") as! HowToRideSinglePageViewController
    viewController.descriptionText = withDescription
    return viewController
  }
  
}

extension HowToRideViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
  
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
    let previousIndex = viewControllerIndex - 1
    guard previousIndex >= 0 else { return pages.last }
    guard pages.count > previousIndex else { return nil }
    return pages[previousIndex]
  }
  

  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
    let nextIndex = viewControllerIndex + 1
    guard nextIndex < pages.count else { return pages.first }
    guard pages.count > nextIndex else { return nil }
    return pages[nextIndex]
  }

}
