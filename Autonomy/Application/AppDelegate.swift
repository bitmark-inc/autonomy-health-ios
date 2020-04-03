//
//  AppDelegate.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/25/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Intercom
import SVProgressHUD
import OneSignal
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        // init BitmarkSDK environment & api_token
        BitmarkSDKService.setupConfig()

        // SVProgressHUD
        SVProgressHUD.setContainerView(window)
        SVProgressHUD.setMinimumDismissTimeInterval(0.5)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setHapticsEnabled(true)

        // setup Intercom
        Intercom.setApiKey(Constant.intercomAppKey, forAppId: Constant.intercomAppID)

        // IQKeyboardManager
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = false

        // OneSignal
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]

        OneSignal.initWithLaunchOptions(
            launchOptions,
            appId: Constant.oneSignalAppID,
            handleNotificationAction: notificationOpenedBlock,
            settings: onesignalInitSettings
        )

        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        OneSignal.setLocationShared(false)

        UNUserNotificationCenter.current().delegate = self

        // Location permission
        let locationManager = Global.default.locationManager
        locationManager.delegate = self
        locationManager.startUpdatingLocation()

        if #available(iOS 13, *) {
            // already execute app flow in SceneDelegate
        } else {
            Application.shared.presentInitialScreen(
                in: window!,
                fromDeeplink: (launchOptions ?? [:]).count > 0)
        }

        // Override point for customization after application launch.
        return true
    }

    let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
        guard let payload = result?.notification.payload else {
            return
        }

        guard let additionalData = payload.additionalData as? [String: String],
            let helpID = additionalData["help_id"] else {
                return
        }
        Navigator.gotoHelpDetailsScreen(helpRequestID: helpID)
    }

    // MARK: UISceneSession Lifecycle
    func applicationDidEnterBackground(_ application: UIApplication) {
        UserDefaults.standard.enteredBackgroundTime = Date()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        guard Global.current.account != nil else { return }
        Navigator.gotoHealthSurveyScreenIfNeeded()
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

// MARK: - CLLocationManagerDelegate
extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Global.current.userLocationRelay.accept(locations.last)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        let notificationIdentifier = response.notification.request.identifier

        if notificationIdentifier == Constant.NotificationIdentifier.checkInSurvey2 {
            NotificationPermission.restartScheduleReminderNotification()
        }

        if [Constant.NotificationIdentifier.checkInSurvey1, Constant.NotificationIdentifier.checkInSurvey2].contains(notificationIdentifier) {
            Navigator.gotoHealthSurveyScreen()
        }

        completionHandler()
    }
}
