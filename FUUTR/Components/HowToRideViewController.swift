//
//  HowToRideViewController.swift
//  FUUTR
//
//  Copyright © 2019 FUUTR. All rights reserved.
//

import SwiftyUserDefaults

class HowToRideViewController: UIViewController {
  @IBOutlet weak var pageControl: UIPageControl! {
    didSet {
      pageControl.numberOfPages = pages.count
      pageControl.currentPage = 0
      pageControl.tintColor = UIColor.primaryGreyColor
      pageControl.pageIndicatorTintColor = UIColor.primaryGreyColor
      pageControl.currentPageIndicatorTintColor = UIColor.white
      pageControl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    }
  }
  @IBOutlet weak var nextButton: UIButton!
  
  var pageViewController: UIPageViewController? {
    didSet {
      pageViewController?.dataSource = self
      pageViewController?.delegate = self
      
      if let firstViewController = pages.first {
        pageViewController?.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
      }
    }
  }
  
  // MARK: - lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.primaryRedColor
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == R.segue.howToRideViewController.embedPageViewController.identifier,
      let pageViewController = segue.destination as? UIPageViewController {
      self.pageViewController = pageViewController
    }
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - user actions
  @IBAction func nextTapped(_ sender: Any) {
    let currentPageIndex = pageControl.currentPage
    let nextPage = pages[currentPageIndex + 1]
    pageViewController?.setViewControllers([nextPage], direction: .forward, animated: true, completion: nil)
    pageControl.currentPage = currentPageIndex + 1
    nextButton.isHidden = pageControl.currentPage == pages.count - 1
  }
  
  @IBAction func skipTapped(_ sender: Any) {
    Defaults[.userTrainedHowToRide] = true
    performSegue(withIdentifier: R.segue.howToRideViewController.unwindToHome, sender: nil)
  }
  
  // MARK: - private
  private(set) lazy var pages: [UIViewController] = {    
    return [
      R.storyboard.howToRide.page1()!,
      R.storyboard.howToRide.page2()!,
      R.storyboard.howToRide.page3()!,
      R.storyboard.howToRide.page4()!,
      R.storyboard.howToRide.page5()!,
      R.storyboard.howToRide.page6()!,
      R.storyboard.howToRide.page7()!,
    ]
  }()
}

// MARK: - UIPageViewControllerDataSource
extension HowToRideViewController: UIPageViewControllerDataSource {
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

// MARK: - UIPageViewControllerDelegate
extension HowToRideViewController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    let pageContentViewController = pageViewController.viewControllers!.first!
    pageControl.currentPage = pages.index(of: pageContentViewController)!
    
    if pageControl.currentPage < pages.count - 1 {
      nextButton.isHidden = false
    }
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    if pages.index(of: pendingViewControllers.first!) == pages.count - 1 {
      nextButton.isHidden = true
    }
  }
}
