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
}

enum HealthRisk {
    case high, moderate, low

    var color: UIColor {
        switch self {
        case .high:     return UIColor(red: 204, green: 50, blue: 50)!
        case .moderate: return UIColor(red: 241, green: 180, blue: 22)!
        case .low:      return UIColor(red: 45, green: 201, blue: 55)!
        }
    }

    init?(from score: Int) {
        switch score {
        case 0...33:    self = .high
        case 34...66:   self = .moderate
        case 67...100:  self = .low
        default:
            return nil
        }
    }

    var title: String {
        switch self {
        case .high:         return R.string.localizable.highRisk().localizedUppercase
        case .moderate:     return R.string.localizable.moderateRisk().localizedUppercase
        case .low:          return R.string.localizable.lowRisk().localizedUppercase
        }
    }
}
