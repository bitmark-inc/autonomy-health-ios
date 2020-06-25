//
//  DatePeriod.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

struct DatePeriod: Codable {
    let startDate: Date
    var endDate: Date

    func humanize(in timeUnit: TimeUnit) -> String {
        switch timeUnit {
        case .week:
            if startDate.month == endDate.month {
                return startDate.toFormat(Constant.TimeFormat.monthDay) + "-" + endDate.toFormat(Constant.TimeFormat.day)
            } else {
                return startDate.toFormat(Constant.TimeFormat.monthDay) + " - " + endDate.toFormat(Constant.TimeFormat.monthDay)
            }

        case .month:
            if startDate.isInCurrentYear {
                return startDate.toFormat(Constant.TimeFormat.month)
            } else {
                return startDate.toFormat(Constant.TimeFormat.monthYear)
            }

        case .year:
            return startDate.toFormat(Constant.TimeFormat.year)
        }
    }
}

extension Date {
    func toFormat(_ dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
}
