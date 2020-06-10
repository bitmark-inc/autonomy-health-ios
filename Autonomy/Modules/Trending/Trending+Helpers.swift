//
//  Trending+Helpers.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

enum AutonomyObject {
    case individual
    case neighbor
    case poi(poiID: String)
}

enum ReportItemObject {
    case cases
    case symptoms
    case behaviors

    var title: String {
        switch self {
        case .cases:    return R.string.localizable.cases().localizedUppercase
        case .symptoms: return R.string.localizable.symptoms().localizedUppercase
        case .behaviors: return R.string.localizable.behaviors().localizedUppercase
        }
    }
}
