class HowToRideSinglePageViewController: UIViewController {
  
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var skipButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  
  var descriptionText: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    contentView.backgroundColor = UIColor.primaryRedColor
    descriptionLabel.text = descriptionText
  }
}
