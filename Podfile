platform :ios, '11.0'
workspace 'FUUTR'

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
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Stripe'
  pod 'ZendeskSDK'
  pod 'OneSignal'
  
  # UI
  pod 'SideMenu'
  pod 'PKHUD'
  pod 'MZFormSheetPresentationController'
  pod 'PinCodeView'
  pod 'IHKeyboardAvoiding'
  pod 'FlagPhoneNumber'
  pod 'Cosmos'
  pod 'RSKPlaceholderTextView'
  
  # Networking
  pod 'ReachabilitySwift'
  pod 'Kingfisher'
  
  # helpers
  pod 'SwiftyUserDefaults', '4.0.0-alpha.1'
  pod 'R.swift'
  pod 'XCGLogger'
  pod 'ObjectMapper'
  pod 'FastttCamera'
  pod 'EDSunriseSet'

  target 'FUUTR' do

    # Pods for FUUTR
  
  end
  
  target 'FUUTR-staging' do
  
    # Pods for FUUTR-staging
  
  end
  
  target 'FUUTR-dev' do
      
      # Pods for FUUTR-dev
      
  end
end

