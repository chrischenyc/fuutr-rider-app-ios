platform :ios, '11.0'
workspace 'OTGRider'

inhibit_all_warnings!
use_frameworks!

pre_install do |installer|
    # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
    Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end

abstract_target 'Project' do

  # third-party services
  pod 'GoogleMaps'
  pod 'FBSDKLoginKit'
  pod 'Firebase/Core'
  pod 'Firebase/Performance'
  pod 'Firebase/Messaging'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Stripe'
  
  # UI
  pod 'SideMenu'
  pod 'PKHUD'
  pod 'MZFormSheetPresentationController'
  pod 'PinCodeView'
  pod 'IHKeyboardAvoiding'
  
  # Networking
  pod 'ReachabilitySwift'
  
  # helpers
  pod 'SwiftyUserDefaults', '4.0.0-alpha.1'
  pod 'R.swift'
  pod 'XCGLogger'
  pod 'BartyCrouch'
  pod 'PhoneNumberKit'
  pod 'ObjectMapper'
  pod 'FastttCamera'
  pod 'Solar'

  target 'OTGRider' do

    # Pods for OTGRider
  
  end
  
  target 'OTGRider-staging' do
  
    # Pods for OTGRider-staging
  
  end
  
  target 'OTGRider-dev' do
      
      # Pods for OTGRider-dev
      
  end
end

