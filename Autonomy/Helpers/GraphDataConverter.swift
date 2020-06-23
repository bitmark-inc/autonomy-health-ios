//
//  GraphDataConverter.swift
//  Autonomy
//
//  Created by Thuyen Truong on 12/18/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import UIKit
import SwiftDate

class GraphDataConverter {

    // MARK: - Properties
    static let formatInDay = "yyyy-MM-dd"

    // MARK: - Handlers
    static func getDataGroupByDay(with reportItems: [ReportItem], timeUnit: TimeUnit, datePeriod: DatePeriod) -> [Date: [Double]] {
        let dates: [Date] = getDates(datePeriod: datePeriod, with: timeUnit)
        var graphData = [Date: [Double]]()

        for reportItem in reportItems {
            let distribution = reportItem.distribution

            dates.forEach { (date) in
                var dataInIndex = graphData[date] ?? []

                let dateIndex = date.toFormat(formatInDay)
                dataInIndex.append(distribution[dateIndex] ?? 0)

                graphData[date] = dataInIndex
            }
        }

        return graphData
    }

    fileprivate static func getDates(datePeriod: DatePeriod, with timeUnit: TimeUnit) -> [Date] {
        var dates = [Date]()
        var indexDate = datePeriod.startDate

        let indexDateComponent: Calendar.Component!

        switch timeUnit {
        case .week, .month: indexDateComponent = .day
        case .year:         indexDateComponent = .month
        }

        repeat {
            dates.append(indexDate)
            indexDate = indexDate.inDefaultRegion().dateByAdding(1, indexDateComponent).date
        } while indexDate < datePeriod.endDate.beginning(of: indexDateComponent)!

        return dates
    }
}
