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

    typealias ChartInfo = (timeUnit: TimeUnit, datePeriod: DatePeriod)

    // MARK: - Handlers
    static func getDataGroupByDay(with reportItems: [ReportItem], chartInfo: ChartInfo) -> (data: [Date: [Double]], base: Int) {
        let (timeUnit, datePeriod) = (chartInfo.timeUnit, chartInfo.datePeriod)

        let dates: [Date] = getDates(datePeriod: datePeriod, with: timeUnit)
        var graphData = [Date: [Double]]()

        if reportItems.count == 0 {
            dates.forEach { graphData[$0] = [0.0] }
            return (data: graphData, base: 1)
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
                dataInIndex.append(distribution[dateIndex] ?? 0)

                graphData[date] = dataInIndex
            }
        }

        // adjusts with base
        let base: Double!

        let maxValue = graphData.values.map { $0.sum() }.max() ?? 0
        switch maxValue {
        case 0...75:        base = 1
        case 76...375:      base = 5
        default:
            base = 10
        }

        if base > 1 {
            for (date, dataInDate) in graphData {
                let baseDataInDate = dataInDate.map { ($0 / base).rounded(.down) }
                graphData[date] = baseDataInDate
            }
        }

        return (data: graphData, base: Int(base))
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
