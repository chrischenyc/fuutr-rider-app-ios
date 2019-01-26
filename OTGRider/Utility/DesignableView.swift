class DesignableView: UIView {
  
  var nibName = ""
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  func commonInit() {
    guard let view = loadViewFromNib() else { return }
    view.frame = self.bounds
    self.addSubview(view)
  }
  
  func loadViewFromNib() -> UIView? {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: nibName, bundle: bundle)
    return nib.instantiate(withOwner: self, options: nil).first as? UIView
  }
}


