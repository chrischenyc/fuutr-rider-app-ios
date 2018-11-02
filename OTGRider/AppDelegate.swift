//
//  AppDelegate.swift
//  OTGRider
//
//  Created by Chris Chen on 15/10/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit
import GoogleMaps
import FBSDKCoreKit
import FBSDKLoginKit
import SideMenu
import XCGLogger
import SwiftyUserDefaults

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
        
        log.setup(level: logLevel,
                  showLogIdentifier: false,
                  showFunctionName: true,
                  showThreadName: false,
                  showLevel: true,
                  showFileNames: true,
                  showLineNumbers: true,
                  showDate: true,
                  writeToFile: nil,
                  fileLevel: nil)
        
        // third-party services init
        GMSServices.provideAPIKey(configuration.environment.googleMapKey)
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // UI init
        SideMenuManager.defaultManager.menuPresentMode = .menuSlideIn
        SideMenuManager.defaultManager.menuFadeStatusBar = false
        
        // TODO: custom facebook button https://developers.facebook.com/docs/facebook-login/ios/advanced#custom-login-button
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

