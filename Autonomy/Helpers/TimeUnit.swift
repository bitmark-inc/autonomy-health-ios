//
//  TimeUnit.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

enum TimeUnit: String {
    case week
    case month
    case year

    init?(index: Int) {
        switch index {
        case 0: self = .week
        case 1: self = .month
        case 2: self = .year
        default:
            return nil
        }
    }

    var dateComponent: Calendar.Component {
        switch self {
        case .week:     return .weekOfYear
        case .month:    return .month
        case .year:     return .year
        }
    }
}
