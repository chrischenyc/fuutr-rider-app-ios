//
//  AppDelegate.swift
//  OTGRider
//
//  Created by Chris Chen on 15/10/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import UserNotifications
import GoogleMaps
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseMessaging
import SideMenu
import XCGLogger
import SwiftyUserDefaults
import Stripe

// global variables
let logger = XCGLogger.default
var config = Configuration()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // helpers init
    #if DEBUG
    let logLevel: XCGLogger.Level = .debug
    #else
    let logLevel: XCGLogger.Level = .error
    #endif
    
    logger.setup(level: logLevel,
                 showLogIdentifier: false,
                 showFunctionName: false,
                 showThreadName: false,
                 showLevel: true,
                 showFileNames: true,
                 showLineNumbers: true,
                 showDate: true,
                 writeToFile: nil,
                 fileLevel: nil)
    
    // third-party services init
    #if !DEBUG
    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    #endif
    
    GMSServices.provideAPIKey(config.env.googleMapKey)
    FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
    configStripe()
    
    // UI init
    globalStyling()
    
    // TODO: custom facebook button
    // https://developers.facebook.com/docs/facebook-login/ios/advanced#custom-login-button
    // Override point for customization after application launch.
    // [FBSDKLoginButton class];
    
    // load initial screen depending on user signed-in status
    if !Defaults[.userSignedIn] {
      self.window?.rootViewController = UIStoryboard(name: "SignIn", bundle: nil).instantiateInitialViewController()
    } else if !Defaults[.userOnboarded] {
      self.window?.rootViewController = UIStoryboard(name: "Onboard", bundle: nil).instantiateInitialViewController()
    } else {
      self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.handleUserSignedOut), name: .userSignedOut, object: nil)
    
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    
    let handled = FBSDKApplicationDelegate.sharedInstance()
      .application(app,
                   open: url,
                   sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                   annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    
    if !handled {
      // more custom URL scheme handling ...
    }
    
    return handled
  }
}

extension AppDelegate: MessagingDelegate {
  
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    logger.debug("Firebase registration token: \(fcmToken)")
    
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
  }
}

extension AppDelegate {
  @objc func handleUserSignedOut(notification: Notification) {
    guard let signInViewController = UIStoryboard(name: "SignIn", bundle: nil).instantiateInitialViewController() as? SignInViewController else { return }
    
    DispatchQueue.main.async {
      if let window = self.window, let rootViewController = window.rootViewController {
        var currentController = rootViewController
        while let presentedController = currentController.presentedViewController {
          currentController = presentedController
        }
        currentController.present(signInViewController, animated: true, completion: nil)
      }
    }
  }
}

extension AppDelegate {
  private func configStripe() {
    // Stripe payment configuration
    STPPaymentConfiguration.shared().companyName = R.string.localizable.kCompanyName()
    
    if !config.env.stripePublishableKey.isEmpty {
      STPPaymentConfiguration.shared().publishableKey = config.env.stripePublishableKey
    }
    
    if !config.env.appleMerchantIdentifier.isEmpty {
      STPPaymentConfiguration.shared().appleMerchantIdentifier = config.env.appleMerchantIdentifier
    }
    
    // Stripe theme configuration
    STPTheme.default().primaryBackgroundColor = .stripePrimaryBackgroundColor
    STPTheme.default().primaryForegroundColor = .stripePrimaryForegroundColor
    STPTheme.default().secondaryForegroundColor = .stripeSecondaryForegroundColor
    STPTheme.default().accentColor = .stripeAccentColor
  }
}


extension AppDelegate {
  private func globalStyling() {
    SideMenuManager.defaultManager.menuPresentMode = .menuSlideIn
    SideMenuManager.defaultManager.menuFadeStatusBar = false
    
    // TODO: this is overkill, Stripe screen will be affected too
    UINavigationBar.appearance().tintColor = UIColor.primaryRedColor
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.primaryRedColor]
    UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    UINavigationBar.appearance().shadowImage = UIImage()
  }
}
