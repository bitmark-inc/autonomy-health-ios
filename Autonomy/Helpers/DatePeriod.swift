//
//  DatePeriod.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

struct DatePeriod: Codable {
    var startDate: Date
    var endDate: Date

    var fullWeekDate: Date {
        return startDate.beginning(of: .weekOfYear) ?? startDate
    }

    func humanize(in timeUnit: TimeUnit) -> String {
        switch timeUnit {
        case .week:
            if startDate.month == endDate.month {
                return startDate.toFormat(Constant.TimeFormat.monthDay) + "-" + endDate.toFormat(Constant.TimeFormat.day)
            } else {
                return startDate.toFormat(Constant.TimeFormat.monthDay) + " - " + endDate.toFormat(Constant.TimeFormat.monthDay)
            }

        case .month:
            let middleOfMonth = startDate.adding(.day, value: 10) // to ignore when making startDate is full of week
            if middleOfMonth.isInCurrentYear {
                return middleOfMonth.toFormat(Constant.TimeFormat.month)
            } else {
                return middleOfMonth.toFormat(Constant.TimeFormat.monthYear)
            }

        case .year:
            return startDate.toFormat(Constant.TimeFormat.year)
        }
    }
}
