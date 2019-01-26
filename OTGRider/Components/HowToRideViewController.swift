class HowToRideViewController: UIPageViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dataSource = self
    
    if let firstViewController = pages.first {
      setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
    }
  }
  
  private(set) lazy var pages: [UIViewController] = {
    let page1 = getViewController(withDescription: "Push the vehicle twice with your foot to get started.",
                                  imageName: "how-to-ride-1")
    
    let page2 = getViewController(withDescription: "Push down the right hand throttle to use E-Motor.",
                                  imageName: "how-to-ride-2")
    
    let page3 = getViewController(withDescription: "Always keep both feet on the deck of the vehicle while riding.",
                                  imageName: "how-to-ride-3")
    
    let page4 = getViewController(withDescription: "Always use shared paths or bike lanes and always ride to the left.",
                                  imageName: "how-to-ride-4")
    
    let page5 = getViewController(withDescription: "DO NOT ride OTG Ride vehicles on the sidewalk. Follow all road rules.",
                                  imageName: "how-to-ride-5")
    
    let page6 = getViewController(withDescription: "Park your vehicle in a dedicated OTG Ride Parking Hub or close to the curb, out of the way of pedestrians. Your parking compliance is strictly monitored via a photo at the end of ride.",
                                  imageName: "how-to-ride-6")
    
    let page7 = getViewController(withDescription: "At all times please wear either a provided FUUTR helmet or your own personal helmet.",
                                  imageName: "how-to-ride-7")
    page7.isLastPage = true
    
    return [page1, page2, page3, page4, page5, page6, page7]
  }()
  
  fileprivate func getViewController(withDescription: String, imageName: String) -> HowToRideSinglePageViewController
  {
    let viewController = UIStoryboard(name: "HowToRide", bundle: nil).instantiateViewController(withIdentifier: "HowToRideSinglePageViewController") as! HowToRideSinglePageViewController
    viewController.descriptionText = withDescription
    viewController.imageName = imageName
    return viewController
  }
  
}

extension HowToRideViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
  
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
    let previousIndex = viewControllerIndex - 1
    guard previousIndex >= 0 else { return nil }
    guard pages.count > previousIndex else { return nil }
    return pages[previousIndex]
  }
  

  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
    let nextIndex = viewControllerIndex + 1
    guard nextIndex < pages.count else { return nil }
    guard pages.count > nextIndex else { return nil }
    return pages[nextIndex]
  }

}
