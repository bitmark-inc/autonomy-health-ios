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
    static let formatInMonth = "yyyy-MM"

    typealias ChartInfo = (object: ReportItemObject, timeUnit: TimeUnit, datePeriod: DatePeriod)

    // MARK: - Handlers
    static func getDataGroupByDay(with reportItems: [ReportItem], chartInfo: ChartInfo) -> [Date: [Double]] {
        let (reportItemObject, timeUnit, datePeriod) = (chartInfo.object, chartInfo.timeUnit, chartInfo.datePeriod)
        let base: Double = 1

        let dates: [Date] = getDates(datePeriod: datePeriod, with: timeUnit)
        var graphData = [Date: [Double]]()

        if reportItems.count == 0 {
            dates.forEach { graphData[$0] = [0.0] }
            return graphData
        }

        // init graph
        dates.forEach { graphData[$0] = [] }

        let format: String!
        switch timeUnit {
        case .week, .month: format = formatInDay
        case .year:         format = formatInMonth
        }

        for reportItem in reportItems {
            let distribution = reportItem.distribution

            dates.forEach { (date) in
                var dataInIndex = graphData[date] ?? []

                let dateIndex = date.toFormat(format)
                let baseDistribution = ((distribution[dateIndex] ?? 0) / base).rounded(.down)
                dataInIndex.append(baseDistribution)

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
