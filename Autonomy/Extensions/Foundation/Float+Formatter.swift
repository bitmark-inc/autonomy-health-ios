//
//  Float+Formatter.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/4/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

extension Float {
    var formatScoreInt: String {
        return "\(Int(self))"
    }

    var formatPercent: String {
        return String(format: "%.2f", self)
    }
}

extension Int {
    var formatNumber: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}
