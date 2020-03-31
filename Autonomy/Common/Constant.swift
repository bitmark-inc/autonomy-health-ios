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

    public struct OneSignalTag {
        public static let key = "account_number"
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
