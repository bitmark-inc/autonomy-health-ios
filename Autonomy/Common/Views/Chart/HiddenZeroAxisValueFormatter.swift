//
//  HiddenZeroAxisValueFormatter.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Charts

final class HiddenZeroAxisValueFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if value <= 0 {
            return ""
        }

        return "\(Int(value))"
    }
}
