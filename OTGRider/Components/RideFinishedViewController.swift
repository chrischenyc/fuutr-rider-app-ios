class RideFinishedViewController: UIViewController {
  
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var rideUsedTimeLabel: UILabel!
  @IBOutlet weak var rideFinishedTimeLabel: UILabel!
  @IBOutlet weak var rideEndedLabel: UILabel!
  @IBOutlet weak var rideDistanceLabel: UILabel!
  @IBOutlet weak var costLabel: UILabel!
  @IBOutlet weak var shareLabel: UILabel!
  @IBOutlet weak var reportButton: UIButton!
  @IBOutlet weak var continueButton: UIButton!
  
  private let streetZoomLevel: Float = 14.0
  private var ongoingRidePolyline: GMSPolyline?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    continueButton.primaryRed()
    reportButton.primaryDarkBasic()

    shareLabel.textColor = UIColor.primaryDarkColor
    rideEndedLabel.textColor = UIColor.primaryGreyColor
    rideFinishedTimeLabel.textColor = UIColor.primaryDarkColor
    
    continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    
    do {
      // Set the map style by passing the URL of the local file.
      if let styleURL = Bundle.main.url(forResource: "GoogleMapStyle", withExtension: "json") {
        mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
      } else {
        logger.error("Unable to find style.json")
      }
    } catch {
      logger.error("One or more of the map styles failed to load. \(error)")
    }
  }
  
  func updateContent(with ride: Ride, and location: CLLocation?) {
    costLabel.text = ride.totalCost.currencyString
    rideUsedTimeLabel.text = ride.duration.hhmmssString
    rideDistanceLabel.text = ride.distance.distanceString
    rideFinishedTimeLabel.text = ride.lockTime?.dateTimeString
    
    if let location = location {
      let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: streetZoomLevel)
      mapView.animate(to: camera)
    }
    
    if let encodedPath = ride.encodedPath, let decodedPath = GMSMutablePath(fromEncodedPath: encodedPath){
      
      drawRoute(forPath: decodedPath)
    }
  }
  
  private func drawRoute(forPath path: GMSPath?) {
    ongoingRidePolyline = GMSPolyline(path: path)
    ongoingRidePolyline?.strokeWidth = 4
    ongoingRidePolyline?.strokeColor = UIColor.primaryRedColor
    ongoingRidePolyline?.map = mapView
  }
  
  @objc private func continueButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }
}
