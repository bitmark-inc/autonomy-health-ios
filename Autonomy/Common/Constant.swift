//
//  Constant.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/25/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit

public struct Constant {

    static let appName = "Autonomy"
    static let apiServerURL = Credential.valueForKey(keyName: "API_SERVER_URL")
    static let intercomAppID = Credential.valueForKey(keyName: "INTERCOM_APP_ID")
    static let intercomAppKey = Credential.valueForKey(keyName: "INTERCOM_APP_KEY")
    static let oneSignalAppID = Credential.valueForKey(keyName: "ONESIGNAL_APP_ID")
    static let sentryDSN = Credential.valueForKey(keyName: "SENTRY_DSN")
    static let googleAPIKey = Credential.valueForKey(keyName: "GOOGLE_API_KEY")

    public struct OneSignal {
        struct Tags {
            public static let key = "account_number"
        }

        struct TypeKey {
            public static let broadCastNewHelp = "BROADCAST_NEW_HELP"
            public static let notifyHelpSigned = "NOTIFY_HELP_ACCEPTED"
            public static let notifyHelpExired = "NOTIFY_HELP_EXPIRED"
        }
    }

    public struct NotificationIdentifier {
        public static let checkInSurvey1 = "check-in-survey-1"
        public static let checkInSurvey2 = "check-in-survey-2"
    }

    public struct HeathColor {
        public static let red = UIColor(hexString: "#CC3232")!
        public static let yellow = UIColor(hexString: "#E7B416")!
        public static let green = UIColor(hexString: "#2DC937")!
    }
}
