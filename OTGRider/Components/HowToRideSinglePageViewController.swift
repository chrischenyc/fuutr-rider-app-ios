class HowToRideSinglePageViewController: UIViewController {
  
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var skipButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  
  var descriptionText: String?
  var imageName: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    contentView.backgroundColor = UIColor(red:0.93, green:0.11, blue:0.14, alpha:1)
    descriptionLabel.text = descriptionText
    imageView.image = UIImage(named: imageName ?? "how-to-ride-1")
  }
}
