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

        notificationCenter.getPendingNotificationRequests { (requests) in
            guard requests.isEmpty else { return } // only one kind of notification; don't need to clear which identifier

            let requests = makeScheduledCheckInSurveyRequest()
            requests.forEach { notificationCenter.add($0) }
        }
    }

    static func restartScheduleReminderNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()

        let requests = makeScheduledCheckInSurveyRequest()
        requests.forEach { notificationCenter.add($0) }
    }

    fileprivate static func makeScheduledCheckInSurveyRequest() -> [UNNotificationRequest] {
        return random2NotificationTimes().enumerated().map { (index, notificationTime) -> UNNotificationRequest in
            #if targetEnvironment(simulator)
            var triggerDate = DateComponents()
            triggerDate.second = Int.random(in: 0...59)

            #else
            var triggerDate = DateComponents()
            triggerDate.hour = notificationTime
            triggerDate.minute = Int.random(in: 0...59)

            #endif

            Global.log.debug("[setup checkInSurvey] in \(triggerDate)")

            let content = makeCheckInSurveyNotification()
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)

            let identifier = index == 0 ?
                Constant.NotificationIdentifier.checkInSurvey1 :
                Constant.NotificationIdentifier.checkInSurvey2
            return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        }
    }

    static func random2NotificationTimes() -> [Int] {
        let number1 = Int.random(in: 9...20) // random from 9am - 9pm; 8pm (20) cause we have minutes later
        var number2: Int!

        repeat {
            number2 = Int.random(in: 9...20)
        } while abs(number2 - number1) < 3

        return [number1, number2].sorted()
    }

    fileprivate static func makeCheckInSurveyNotification() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = R.string.phrase.notificationSurveyTitle()
        content.body = R.string.phrase.notificationSurveyDesc()
        content.sound = UNNotificationSound.default
        content.badge = 1
        return content
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
