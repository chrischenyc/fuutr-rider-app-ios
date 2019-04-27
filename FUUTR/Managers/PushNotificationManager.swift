//
//  PushNotificationManager.swift
//  FUUTR
//
//  Created by Chris Chen on 27/4/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import Foundation
import OneSignal
import SwiftyUserDefaults

protocol PushNotificationManagerProtocol {
    func refreshPushNotificationSubscriptionStatus()
    func handlePushNotificationSubscriptionState(_ state: OSSubscriptionState)
}

class PushNotificationManager: PushNotificationManagerProtocol {
    static let shared = PushNotificationManager()
    
    func refreshPushNotificationSubscriptionStatus() {
        if let status = OneSignal.getPermissionSubscriptionState(), status.permissionStatus.hasPrompted {
            handlePushNotificationSubscriptionState(status.subscriptionStatus)
        }
    }
    
    func handlePushNotificationSubscriptionState(_ state: OSSubscriptionState) {
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
