//
//  AppLink.swift
//  Autonomy
//
//  Created by Thuyen Truong on 1/14/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

enum AppLink: String {
    case eula
    case privacyOfPolicy = "legal-privacy"
    case incomeQuestion = "income-question"
    case faq
    case support
    case viewRecoveryKey = "view-recovery-key"
    case exportData = "export-data"
    case personalAPI = "personal-api"
    case sourceCode = "source-code"
    case digitalRights = "digital-rights"

    var path: String {
        return Constant.appName + "://\(rawValue)"
    }

    var generalText: String {
        switch self {
        case .eula:                 return R.string.phrase.eula()
        case .privacyOfPolicy:      return R.string.phrase.privacyPolicy()
        case .digitalRights:        return R.string.localizable.digitalRights()
        default:
            return ""
        }
    }

    var websiteURL: URL? {
        let serverURL = "https://raw.githubusercontent.com/bitmark-inc/spring/master"

        switch self {
        case .eula:             return URL(string: "https://bitmark.com")
        case .privacyOfPolicy:  return URL(string: "https://bitmark.com")
        case .faq:              return URL(string: serverURL + "/faq.md")
        case .personalAPI:      return URL(string: "https://documenter.getpostman.com/view/59304/SzRw2rJn?version=latest")
        case .sourceCode:       return URL(string: "https://github.com/bitmark-inc/spring-ios")
        case .digitalRights:    return URL(string: "https://bitmark.com")
        default:
            return nil
        }
    }
}
