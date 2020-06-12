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
            public static let riskLevelChanged = "RISK_LEVEL_CHANGED"                  // NSC1-2
            public static let accountSymptomSpike = "ACCOUNT_SYMPTOM_SPIKE"            // NSY1
            public static let accountSymptomFollowUp = "ACCOUNT_SYMPTOM_FOLLOW_UP"     // NSY2
            public static let behaviorOnRiskArea = "BEHAVIOR_REPORT_ON_RISK_AREA"        // NB1
            public static let behaviorSelfRiskArea = "BEHAVIOR_REPORT_ON_SELF_HIGH_RISK"   // NB3
        }
    }

    public struct NotificationIdentifier {
        public static let cleanAndDisinfectSurfaces = "clean-and-disinfect-surfaces";
    }


    public struct  SettingsBundle {
        struct Keys {
            static let kVersion = "CFBundleShortVersionString"
            static let kBundle = "CFBundleVersion"
        }
    }

    struct TimeFormat {
        static let history = "MMM d 'at' h:mm a"
        static let monthDay = "MMM d"
        static let month = "MMM"
        static let day = "d"
        static let year = "yyyy"
        static let monthYear = "yyyy MMM"
    }

    static let fieldPlaceholder = "---"
    static let skeletonColor = UIColor(red: 0.109804, green: 0.137255, blue: 0.145098, alpha: 1)
    static let callHistoryLimit = 20
    static let negativeColor = UIColor(hexString: "#CC3232")
    static let positiveColor = UIColor(hexString: "#2DC937")
    static let lineHealthDataWidth: CGFloat = Size.dw(105)
}

enum HealthRisk {
    case high, moderate, low, zero

    var color: UIColor {
        switch self {
        case .zero:     return UIColor(hexString: "#828180")!
        case .high:     return UIColor(red: 204, green: 50, blue: 50)!
        case .moderate: return UIColor(red: 241, green: 180, blue: 22)!
        case .low:      return UIColor(red: 45, green: 201, blue: 55)!
        }
    }

    init?(from score: Int) {
        switch score {
        case 0:         self = .zero
        case 0...33:    self = .high
        case 34...66:   self = .moderate
        case 67...:  self = .low
        default:
            return nil
        }
    }

    init?(from score: Float) {
        switch Int(score.rounded()) {
        case 0:         self = .zero
        case 0...33:    self = .high
        case 34...66:   self = .moderate
        case 67...:  self = .low
        default:
            return nil
        }
    }
}

enum Rating {
    case good
    case medium
    case low

    init(from score: Float) {
        switch (score) {
        case _ where score >= 3.3:  self = .good
        case _ where score <= 1.6:  self = .low
        default:
            self = .medium
        }
    }

    var color: UIColor {
        switch self {
        case .good:    return UIColor(hexString: "#2DC937")!
        case .medium:  return UIColor(hexString: "#E7B416")!
        case .low:     return UIColor(hexString: "#CC3232")!
        }
    }
}
