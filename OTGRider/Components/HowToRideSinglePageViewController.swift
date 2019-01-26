import SwiftyUserDefaults

protocol HowToRideSinglePageDelegate {
  func ride()
  func showNextPage()
}

class HowToRideSinglePageViewController: UIViewController {
  
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var skipButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var rideButton: UIButton!
  @IBOutlet weak var nextButton: UIButton!
  
  var delegate: HowToRideSinglePageDelegate?
  
  var descriptionText: String?
  var imageName: String?
  var isLastPage: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    contentView.backgroundColor = UIColor.primaryRedColor
    descriptionLabel.text = descriptionText
    imageView.image = UIImage(named: imageName ?? "how-to-ride-1")
    
    if isLastPage {
      rideButton.isHidden = false
      rideButton.layer.cornerRadius = 5
      nextButton.isHidden = true
    }
    
    nextButton.addTarget(self, action: #selector(showNextPage), for: .touchUpInside)
    skipButton.addTarget(self, action: #selector(skip), for: .touchUpInside)
    rideButton.addTarget(self, action: #selector(ride), for: .touchUpInside)
  }
  
  @objc func showNextPage() {
    delegate?.showNextPage()
  }
  
  @objc func skip() {
    DispatchQueue.main.async {
      Defaults[.userTrainedHowToRide] = true
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  @objc func ride() {
    delegate?.ride()
  }
}
