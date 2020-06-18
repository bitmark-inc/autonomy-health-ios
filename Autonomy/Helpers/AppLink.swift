//
//  AppLink.swift
//  Autonomy
//
//  Created by Thuyen Truong on 1/14/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

enum AppLink: String {
    case signIn = "sign-in"
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
    case coronaDataCraper = "corona-data-craper"
    case formulaJupyter = "formula-jupyter"

    var path: String {
        return Constant.appName + "://\(rawValue)"
    }

    var appURL: URL? {
        return URL(string: path)
    }

    var websiteURL: URL? {
        let serverURL = "https://raw.githubusercontent.com/bitmark-inc/autonomy/master"

        switch self {
        case .eula:             return URL(string: "https://bitmark.com")
        case .privacyOfPolicy:  return URL(string: "https://bitmark.com/privacy")
        case .faq:              return URL(string: serverURL + "/faq.md")
        case .personalAPI:      return URL(string: "https://documenter.getpostman.com/view/59304/SzRw2rJn?version=latest")
        case .sourceCode:       return URL(string: "https://github.com/bitmark-inc/autonomy-ios")
        case .digitalRights:    return URL(string: "https://bitmark.com/privacy")
        case .coronaDataCraper: return URL(string: "https://coronadatascraper.com")
        case .formulaJupyter:   return URL(string: "https://nbviewer.jupyter.org/github/bitmark-inc/autonomy-api/blob/master/share/jupyter/autonomyFormula.ipynb")
        default:
            return nil
        }
    }
}
