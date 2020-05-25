//
//  NotificationPermission.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import OneSignal
import UserNotifications

class NotificationPermission {
    static func askForNotificationPermission(handleWhenDenied: Bool) -> Single<UNAuthorizationStatus> {
        return Single<UNAuthorizationStatus>.create { (event) -> Disposable in
            let notificationCenter = UNUserNotificationCenter.current()

            notificationCenter.getNotificationSettings { (settings) in

                let notifyStatus = settings.authorizationStatus
                switch notifyStatus {
                case .notDetermined:
                    let options: UNAuthorizationOptions = [.alert, .sound, .badge]
                    notificationCenter.requestAuthorization(options: options) { (didAllow, error) in
                        if let error = error {
                            event(.error(error))
                        } else {
                            didAllow ? event(.success(.authorized)) : event(.success(.denied))
                        }
                    }

                case .denied:
                    handleWhenDenied ? askEnableNotificationAlert() : event(.success(.denied))

                case .authorized, .provisional:
                    event(.success(notifyStatus))
                @unknown default:
                    break
                }
            }

            return Disposables.create()
        }
    }

    static func isEnabled() -> Single<Bool?> {
        return Single<Bool?>.create { (event) -> Disposable in
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                switch settings.authorizationStatus {
                case .notDetermined:
                    event(.success(nil))
                case .authorized, .provisional:
                    event(.success(true))
                default:
                    event(.success(false))
                }
            }

            return Disposables.create()
        }
    }

    static func registerOneSignal() {
        guard let accountNumber = Global.current.account?.getAccountNumber() else {
            Global.log.error(AppError.emptyCurrentAccount)
            return
        }

        Global.log.info("[process] registerOneSignal: \(accountNumber)")
        OneSignal.promptForPushNotifications(userResponse: { _ in
            OneSignal.sendTags([
                Constant.OneSignal.Tags.key: accountNumber
            ])
            OneSignal.setSubscription(true)
        })
    }

    static func scheduleReminderNotificationIfNeeded() {
        let notificationCenter = UNUserNotificationCenter.current()

        notificationCenter.removeAllPendingNotificationRequests()

        notificationCenter.getPendingNotificationRequests { (requests) in
            let _ = requests.map { $0.identifier }
            resetNotifications() // only for updating locale for now
        }
    }

    static func resetNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [
            Constant.NotificationIdentifier.cleanAndDisinfectSurfaces
        ])

        let request = makeScheduledCleanAndDisinfectSurfacesRequest()
        notificationCenter.add(request)
        Global.log.debug("[notification] schedules for [clean And Disinfect Surfaces] notification")
    }

    static func random2NotificationTimes(awayFromNow: Bool = false) -> [Int] {
        let number1 = randomHour(awayFromNow: awayFromNow) // random from 9am - 9pm; 8pm (20) cause we have minutes later
        var number2: Int!

        repeat {
            number2 = randomHour(awayFromNow: awayFromNow)
        } while abs(number2 - number1) <= 4

        return [number1, number2].sorted()
    }

    static func randomHour(awayFromNow: Bool) -> Int {
        if !awayFromNow {
            return Int.random(in: 9...20)
        }

        var number: Int!
        let currentHour = Date().hour
        repeat {
            number = Int.random(in: 9...20)
        } while number <= currentHour + 4 && number >= currentHour
        return number
    }

    fileprivate static func askEnableNotificationAlert() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: R.string.error.notificationTitle(),
                message: R.string.error.notificationMessage(),
                preferredStyle: .alert)

            let cancelAction = UIAlertAction(
                title: R.string.localizable.cancel(),
                style: .cancel, handler: nil)

            let enableAction = UIAlertAction(
                title: R.string.localizable.enable(),
                style: .default, handler: self.openAppSettings)

            alertController.addAction(cancelAction)
            alertController.addAction(enableAction)
            alertController.preferredAction = enableAction

            alertController.show()
        }
    }

    @objc static func openAppSettings(_ sender: UIAlertAction) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension NotificationPermission {
    fileprivate static func makeScheduledCleanAndDisinfectSurfacesRequest() -> UNNotificationRequest {
        let content = makeCleanAndDisinfectSurfacesNotification()
        var triggerDate = DateComponents(); triggerDate.hour = 9 // 9 am everyday
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)

        return UNNotificationRequest(
            identifier: Constant.NotificationIdentifier.cleanAndDisinfectSurfaces,
            content: content, trigger: trigger)
    }
}

extension NotificationPermission {
    fileprivate static func makeCleanAndDisinfectSurfacesNotification() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = R.string.phrase.notificationCleanAndDisinfectSurfacesTitle()
        content.body = R.string.phrase.notificationCleanAndDisinfectSurfacesDesc()
        content.sound = UNNotificationSound.default
        content.badge = 1
        return content
    }
}
