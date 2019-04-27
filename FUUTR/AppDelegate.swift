//
//  AppDelegate.swift
//  FUUTR
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
import SideMenu
import XCGLogger
import SwiftyUserDefaults
import Stripe
import ZendeskSDK
import ZendeskCoreSDK
import OneSignal

// global variables
let logger = XCGLogger.default
var remoteConfig: RemoteConfig?
var config = Configuration()
var currentLocation: CLLocation?
var currentUser: User? {
    didSet {
        if oldValue == nil && currentUser != nil {
            NotificationCenter.default.post(name: NSNotification.Name.userSignedIn, object: nil)
        }
        else if oldValue != nil && currentUser == nil {
            NotificationCenter.default.post(name: NSNotification.Name.userSignedOut, object: nil)
        }
        else {
            // user profile gets updated
            if oldValue?.photo != currentUser?.photo {
                NotificationCenter.default.post(name: NSNotification.Name.userAvatarUpdated, object: nil)
            }
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var mainCoordinator: MainCoordinator?
    
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
        if config.env != .Development {
            FirebaseApp.configure()
            
            if let oneSignalAppId = config.env.oneSignalAppId {
                // https://documentation.onesignal.com/docs/ios-native-sdk
                let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
                OneSignal.initWithLaunchOptions(launchOptions,
                                                appId: oneSignalAppId,
                                                handleNotificationAction: nil,
                                                settings: onesignalInitSettings)
                OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
                OneSignal.add(self as OSSubscriptionObserver)
                
                refreshPushNotificationSubscriptionStatus()
            }
        }
        
        GMSServices.provideAPIKey(config.env.googleMapKey)
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        Zendesk.initialize(appId: config.env.zenDeskAppId, clientId: config.env.zenDeskClientId, zendeskUrl: config.env.zenDeskUrl)
        Support.initialize(withZendesk: Zendesk.instance)
        Zendesk.instance?.setIdentity(Identity.createAnonymous())
        
        getRemoteConfig()
        globalStyling()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserSignedIn), name: .userSignedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserSignedOut), name: .userSignedOut, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestPushNotification), name: .requestPushNotification, object: nil)
        
        let navigationController = UINavigationController()
        mainCoordinator = MainCoordinator(navigationController: navigationController)
        mainCoordinator?.start()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
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

// MARK: - Push Notification
extension AppDelegate: OSSubscriptionObserver {
    @objc func requestPushNotification(notif: Notification) {
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            if accepted {
                logger.debug("Push granted")
            }
            else {
                logger.debug("Push denied")
            }
        })
    }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        handlePushNotificationSubscriptionState(stateChanges.to)
    }
    
    private func refreshPushNotificationSubscriptionStatus() {
        if let status = OneSignal.getPermissionSubscriptionState(), status.permissionStatus.hasPrompted {
            handlePushNotificationSubscriptionState(status.subscriptionStatus)
        }
    }
    
    private func handlePushNotificationSubscriptionState(_ state: OSSubscriptionState) {
        guard currentUser != nil else { return }
        
        var payload: JSON = [:]
        
        if state.subscribed {
            if let userId = state.userId {
                payload["oneSignalPlayerId"] = userId
            }
            if let token = state.pushToken {
                payload["applePushDeviceToken"] = token
            }
        }
        else if !state.subscribed && Defaults[.didRequestPushNotificationPermission] {
            // previously opted-in user now opted out, clearn up server record
            payload["oneSignalPlayerId"] = ""
            payload["applePushDeviceToken"] = ""
        }
        
        if payload.count > 0 {
            _ = UserService.updateProfile(payload) { (error) in
                if let error = error {
                    logger.error("Couldn't update user push data: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - private
extension AppDelegate {
    @objc func handleUserSignedIn(notification: Notification) {
        if let currentUser = currentUser {
            Zendesk.instance?.setIdentity(Identity.createAnonymous(name: currentUser.displayName, email: currentUser.email))
        }
        
        refreshPushNotificationSubscriptionStatus()
    }
    
    @objc func handleUserSignedOut(notification: Notification) {
        guard let welcomeViewController = R.storyboard.welcome().instantiateInitialViewController() as? WelcomeViewController else { return }
        
        DispatchQueue.main.async {
            if let window = self.window, let rootViewController = window.rootViewController {
                var currentController = rootViewController
                while let presentedController = currentController.presentedViewController {
                    currentController = presentedController
                }
                currentController.present(welcomeViewController, animated: true, completion: nil)
            }
        }
    }
    
    private func globalStyling() {
        // custom navi bar back button
        UINavigationBar.appearance().backIndicatorImage = R.image.icBackDarkGray16()
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = R.image.icBackDarkGray16()
        
        SideMenuManager.defaultManager.menuPresentMode = .menuSlideIn
        SideMenuManager.defaultManager.menuFadeStatusBar = false
        
        // TODO: custom facebook button
        // https://developers.facebook.com/docs/facebook-login/ios/advanced#custom-login-button
        // Override point for customization after application launch.
        // [FBSDKLoginButton class];
        
        // Stripe payment configuration
        STPPaymentConfiguration.shared().companyName = R.string.localizable.kCompanyName()
        
        if !config.env.stripePublishableKey.isEmpty {
            STPPaymentConfiguration.shared().publishableKey = config.env.stripePublishableKey
        }
        
        if !config.env.appleMerchantIdentifier.isEmpty {
            STPPaymentConfiguration.shared().appleMerchantIdentifier = config.env.appleMerchantIdentifier
        }
        
        // Stripe theme configuration
        STPTheme.default().accentColor = .stripeAccentColor
    }
    
    private func getRemoteConfig() {
        _ = RemoteConfigService.getConfig { (config, error) in
            guard error == nil else {
                logger.error("Couldn't get remote config: \(error!.localizedDescription)")
                return
            }
            
            remoteConfig = config
            NotificationCenter.default.post(name: NSNotification.Name.remoteConfigFetched, object: nil)
        }
    }
}
