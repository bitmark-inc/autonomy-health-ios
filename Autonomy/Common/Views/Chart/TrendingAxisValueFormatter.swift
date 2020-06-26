//
//  TrendingAxisValueFormatter.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Charts

final class TrendingAxisValueFormatter: IAxisValueFormatter {

    // MARK: - Properties
    fileprivate let base: Int!

    init(base: Int) {
        self.base = base
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if value <= 0 {
            return ""
        }

        return "\(Int(value * Double(base)))"
    }
}
