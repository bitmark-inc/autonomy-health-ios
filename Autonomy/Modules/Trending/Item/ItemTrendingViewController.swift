//
//  ItemTrendingViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftRichString
import Charts

class ItemTrendingViewController: ViewController, BackNavigator {

    // MARK: - Properties
    fileprivate lazy var scrollView = makeScrollView()
    fileprivate lazy var headerScreen: UIView = {
        HeaderView(header: thisViewModel.reportItemObject.title)
    }()
    fileprivate lazy var timelineView = TimeFilterView()
    fileprivate lazy var chart = makeChart()
    fileprivate lazy var chartView = makeChartView()
    fileprivate lazy var chartBaseView = makeChartBaseView()
    fileprivate lazy var dataView = makeDataView()
    fileprivate lazy var dataStackView = makeDataStackView()
    fileprivate lazy var emptyDataLabel = makeEmptyDataLabel()
    fileprivate lazy var graphComingSoonLabel = makeGraphComingSoonLabel()
    fileprivate lazy var nullDataLabel = makeNullDataLabel()

    fileprivate lazy var backButton = makeLightBackItem()
    fileprivate lazy var reportButton = makeReportButton()
    fileprivate lazy var groupsButton: UIView = {
        let groupView = ButtonGroupView(button1: backButton, button2: reportButton, hasGradient: false)
        groupView.apply(backgroundStyle: .codGrayBackground)
        return groupView
    }()
    fileprivate lazy var loadIndicator = makeLoadIndicator()

    fileprivate lazy var thisViewModel: ItemTrendingViewModel = {
        return viewModel as! ItemTrendingViewModel
    }()

    fileprivate var itemIDs = [String]()
    fileprivate var currentColorIndex = 0 {
        didSet {
            if currentColorIndex >= graphColorsSet.count || currentColorIndex <= -1 {
                self.currentColorIndex = 0
            }
        }
    }

    fileprivate var itemNoOfBricks = [Int]()
    fileprivate var itemGraphColors = [UIColor]()
    fileprivate var removedGraphColors = [UIColor]()
    fileprivate let graphLabelTextColor = UIColor(hexString: "#BFBFBF")!
    fileprivate let grayColor = UIColor(hexString: "#2B2B2B")!
    fileprivate let graphColorsSet = [
            UIColor(hexString: "#81CFFA"),
            UIColor(hexString: "#E3C878"),
            UIColor(hexString: "#E688A1"),
            UIColor(hexString: "#BBEAA6"),
            UIColor(hexString: "#ED9A73"),
            UIColor(hexString: "#E29AF4")
        ]

    override func bindViewModel() {
        super.bindViewModel()

        timelineView.timeInfoRelay
            .filterNil()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.thisViewModel.fetchTrending(in: $0.period, timeUnit: $0.unit)
            })
            .disposed(by: disposeBag)

        thisViewModel.reportItemsRelay
            .filterNil()
            .subscribe(onNext: { [weak self] (reportItems) in
                guard let self = self else { return }
                self.rebuildScoreView(with: reportItems)

                let emptyData = reportItems.count == 0
                self.emptyDataLabel.isHidden = !emptyData
                self.dataView.isHidden = emptyData
            })
            .disposed(by: disposeBag)

        observeReportItemToDrawChart()
    }

    override func setupViews() {
        super.setupViews()

        // *** Setup subviews ***
        let paddingContentView = LinearView(
            items: [
                (headerScreen, 0),
                (timelineView, 10),
                (chartView, 12),
                (dataView, 30)
            ], bottomConstraint: true)

        paddingContentView.addSubview(emptyDataLabel)
        emptyDataLabel.snp.makeConstraints { (make) in
            make.top.equalTo(chartView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview()
        }

        scrollView.addSubview(paddingContentView)
        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
        }

        paddingContentView.addSubview(loadIndicator)
        loadIndicator.snp.makeConstraints { (make) in
            make.top.equalTo(timelineView.snp.bottom).offset(15)
            make.leading.equalToSuperview()
        }

        contentView.addSubview(scrollView)
        contentView.addSubview(groupsButton)

        scrollView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(groupsButton.snp.top).offset(-5)
        }

        groupsButton.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
        }

        view.addGestureRecognizer(makeLeftSwipeGesture())
        view.addGestureRecognizer(makeRightSwipeGesture())
    }

    fileprivate func rebuildScoreView(with reportItems: [ReportItem]) {
        dataStackView.removeArrangedSubviews()
        dataStackView.removeSubviews()

        let reportItemsCount = reportItems.count

        let newArrangedSubviews = reportItems.enumerated().map { (index, reportItem) -> UIView in
            let healthDataRow = HealthDataRow(info: reportItem.name.localizedUppercase, hasDot: true)
            healthDataRow.setData(reportItem: reportItem, thingType: parseThing())

            if let reportItemValue = reportItem.value, reportItemValue > 0 {
                healthDataRow.addGestureRecognizer(makeTapItemGesture())
            }

            if index < reportItemsCount - 1 { // not add separateLine to last row
                healthDataRow.addSeparateLine()
            }

            return healthDataRow
        }

        if reportItemsCount == 1 && reportItems.first?.value == nil {
            nullDataLabel.isHidden = false
            graphComingSoonLabel.isHidden = true
        }

        dataStackView.addArrangedSubviews(newArrangedSubviews)
    }

    fileprivate func parseThing() -> ThingType {
        switch thisViewModel.reportItemObject {
        case .symptoms:     return .bad
        case .behaviors:    return .good
        case .cases:        return .bad
        default:
            return .bad
        }
    }
}

// MARK: - Navigator
extension ItemTrendingViewController: UITextViewDelegate {
    fileprivate func gotoReportScreen() {
        switch thisViewModel.reportItemObject {
        case .symptoms:
            let viewModel = ReportSymptomsViewModel()
            navigator.show(segue: .reportSymptoms(viewModel: viewModel), sender: self)

        case .behaviors:
            let viewModel = ReportBehaviorsViewModel()
            navigator.show(segue: .reportBehaviors(viewModel: viewModel), sender: self)

        default:
            return
        }
    }
}

// MARK: - Setup views
extension ItemTrendingViewController {
    fileprivate func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.contentInset = UIEdgeInsets(top: 14, left: 15, bottom: 25, right: 15)
        return scrollView
    }

    fileprivate func makeGraphsComingSoonView() -> UIView {
        let view = UIView()
        view.addSubview(graphComingSoonLabel)
        view.addSubview(nullDataLabel)

        view.snp.makeConstraints { (make) in
            make.height.equalTo(255)
        }

        graphComingSoonLabel.snp.makeConstraints { (make) in
            make.centerX.centerY.width.equalToSuperview()
        }

        nullDataLabel.snp.makeConstraints { (make) in
            make.centerX.centerY.width.equalToSuperview()
        }
        return view
    }

    fileprivate func makeGraphComingSoonLabel() -> Label {
        let label = Label()
        label.textAlignment = .center
        label.apply(text: R.string.localizable.graphs_coming_soon(),
                    font: R.font.atlasGroteskLight(size: 18),
                    themeStyle: .concordColor, lineHeight: 1.25)
        return label
    }

    fileprivate func makeNullDataLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        label.apply(text: R.string.phrase.trendingNoData(),
                    font: R.font.atlasGroteskLight(size: 18),
                    themeStyle: .concordColor, lineHeight: 1.25)
        return label
    }

    fileprivate func makeEmptyDataLabel() -> Label {
        var emptyText = ""
        switch thisViewModel.reportItemObject {
        case .symptoms:     emptyText = R.string.phrase.trendingNoReportSymptoms()
        case .behaviors: emptyText = R.string.phrase.trendingNoReportBehaviors()
        default:
            break
        }

        let label = Label()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        label.apply(text: emptyText,
                   font: R.font.atlasGroteskLight(size: 18),
                   themeStyle: .silverColor, lineHeight: 1.25)
        return label
    }

    fileprivate func makeDataView() -> UIView {
        return LinearView(
            items: [(makeDataStackHeader(), 0), (dataStackView, 0)], bottomConstraint: true)
    }

    fileprivate func makeDataStackHeader() -> UIView {
        switch thisViewModel.reportItemObject {
        case .symptoms:
            return HealthDataHeaderView(
                R.string.localizable.symptom().localizedUppercase,
                R.string.localizable.days().localizedUppercase,
                R.string.localizable.change().localizedUppercase,
                hasDot: true)

        case .behaviors:
            return HealthDataHeaderView(
                R.string.localizable.healthyBehaviors().localizedUppercase,
                R.string.localizable.times().localizedUppercase,
                R.string.localizable.change().localizedUppercase,
                hasDot: true)

        default:
            return UIView()
        }
    }

    fileprivate func makeDataStackView() -> UIStackView {
        return UIStackView(arrangedSubviews: [], axis: .vertical, spacing: 0)
    }

    fileprivate func makeReportButton() -> UIButton? {
        if thisViewModel.reportItemObject == .cases {
            return nil
        }

        let button = RightIconButton(
            title: R.string.localizable.report().localizedUppercase,
            icon: R.image.plusCircle()!)
        button.rx.tap.bind { [weak self] in
            self?.gotoReportScreen()
        }.disposed(by: disposeBag)
        return button
    }

    fileprivate func makeLoadIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView()
        indicator.style = .white

        thisViewModel.fetchTrendingStateRelay
            .map { $0 == .loading }
            .bind(to: indicator.rx.isAnimating)
            .disposed(by: disposeBag)

        return indicator
    }

    fileprivate func makeLeftSwipeGesture() -> UISwipeGestureRecognizer {
        let swipeGesture = UISwipeGestureRecognizer()
        swipeGesture.direction = .left
        swipeGesture.rx.event.bind { [weak self] (gesture) in
            guard let self = self else { return }
            self.timelineView.adjustSegment(isNext: true)
        }.disposed(by: disposeBag)
        return swipeGesture
    }

    fileprivate func makeRightSwipeGesture() -> UISwipeGestureRecognizer {
        let swipeGesture = UISwipeGestureRecognizer()
        swipeGesture.direction = .right
        swipeGesture.rx.event.bind { [weak self] (gesture) in
            guard let self = self else { return }
            self.timelineView.adjustSegment(isNext: false)

        }.disposed(by: disposeBag)
        return swipeGesture
    }

    fileprivate func makeChartBaseView() -> UIView {
        switch thisViewModel.reportItemObject {
        case .behaviors:
            let label = Label()
            label.apply(text: " = 10 \(R.string.localizable.behaviors())".localizedUppercase,
                        font: R.font.atlasGroteskLight(size: 12),
                        themeStyle: .silverColor)

            let base = UIView()
            themeService.rx
                .bind({ $0.silverColor }, to: base.rx.backgroundColor)
                .disposed(by: disposeBag)

            let view = UIView()
            view.addSubview(base)
            view.addSubview(label)
            view.isHidden = true

            base.snp.makeConstraints { (make) in
                make.leading.centerY.equalToSuperview()
                make.height.equalTo(2)
                make.width.equalTo(25)
            }

            label.snp.makeConstraints { (make) in
                make.leading.equalTo(base.snp.trailing)
                make.top.trailing.bottom.equalToSuperview()
            }

            return view
        default:
            return UIView()
        }
    }

    fileprivate func makeChartView() -> UIView {
        let label = Label()
        label.apply(font: R.font.domaineSansTextLight(size: 10), themeStyle: .silverColor)
        switch thisViewModel.reportItemObject {
        case .symptoms:
            label.text = R.string.localizable.symptoms().localizedUppercase
        case .behaviors:
            label.text = R.string.localizable.behaviors().localizedUppercase
        default:
            break
        }

        let view = UIView()
        view.addSubview(label)
        view.addSubview(chartBaseView)
        view.addSubview(chart)

        label.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview()
        }

        chartBaseView.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.top)
            make.trailing.equalToSuperview()
        }

        chart.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom).offset(-15)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(233)
        }

        return view
    }

    fileprivate func makeChart() -> BarChartView {
        let chartView = BarChartView()
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = true

        chartView.maxVisibleCount = 60
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.dragEnabled = false
        chartView.highlightPerTapEnabled = false

        let xAxis = chartView.xAxis
        xAxis.labelFont = R.font.ibmPlexMonoLight(size: 14)!
        xAxis.labelTextColor = graphLabelTextColor
        xAxis.drawGridLinesEnabled = false
        xAxis.axisLineColor = UIColor(hexString: "#828180")!
        xAxis.axisLineWidth = 1
        xAxis.labelPosition = .bottom
        xAxis.granularity = 1
        xAxis.spaceMax = 0
        xAxis.spaceMin = 0

        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = R.font.ibmPlexMonoLight(size: 14)!
        leftAxis.labelTextColor = graphLabelTextColor
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawAxisLineEnabled = false
        leftAxis.labelPosition = .outsideChart
        leftAxis.labelTextColor = graphLabelTextColor
        leftAxis.granularity = 1
        leftAxis.spaceBottom = 0
        leftAxis.valueFormatter = HiddenZeroAxisValueFormatter()

        chartView.legend.enabled = false
        chartView.rightAxis.enabled = false

        return chartView
    }
}

// MARK: - Chart Handlers
extension ItemTrendingViewController {
    fileprivate func observeReportItemToDrawChart() {
        thisViewModel.reportItemsRelay.filterNil()
            .subscribe(onNext: { [weak self] (reportItems) in
                guard let self = self,
                    let timeInfo = self.timelineView.timeInfoRelay.value else { return }

                let datePeriod = timeInfo.period
                let timeUnit = timeInfo.unit

                let chartInfo = (
                    object: self.thisViewModel.reportItemObject!,
                    timeUnit: timeUnit,
                    datePeriod: datePeriod
                )

                let dataGroupByDay = GraphDataConverter.getDataGroupByDay(with: reportItems, chartInfo: chartInfo)
                let sortedDataGroupByDay = dataGroupByDay.sorted(by: { $0.0 < $1.0 })

                let newData = self.buildChartData(data: sortedDataGroupByDay.map { $0.value.map { Int($0) } })
                let maxValue: Int = Int(newData.map { $0.sum() }.max() ?? 0)
                let multipleOf5MaxValue = maxValue + (5 - maxValue % 5)

                // build BarChartDataEntry
                var barChartDataEntries = [BarChartDataEntry]()
                for (index, dataInDay) in newData.enumerated() {
                    var values = dataInDay
                    let currentSum = Int(values.sum())
                    let extraSum = 5 - currentSum % 5

                    if currentSum <= 0 {
                        values.append(0)
                    } else {
                        values.append(1 / (22 / (Double(multipleOf5MaxValue) / 5)))
                    }

                    values.append(Double(extraSum))

                    let barChartDataEntry = BarChartDataEntry(x: Double(index), yValues: values)
                    barChartDataEntries.append(barChartDataEntry)
                }

                // build labels
                let dates = sortedDataGroupByDay.map { $0.key }
                let labels = self.buildChartLabels(dates: dates, timeUnit: timeUnit)

                self.chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
                self.chart.xAxis.labelCount = labels.count

                self.setChartData(entries: barChartDataEntries)
                self.chartBaseView.isHidden = timeUnit != .year

            })
            .disposed(by: disposeBag)
    }

    fileprivate func buildChartData(data: [[Int]]) -> [[Double]] {
        var newData = Array(repeating: [Double](), count: data.count)
        guard data.count > 0 else { return newData }

        itemNoOfBricks = Array(repeating: 1, count: data.first!.count)

        for i in (0..<data.count) {
            let currentRow = data[i]
            for j in (0..<currentRow.count) {
                itemNoOfBricks[j] = max(itemNoOfBricks[j], currentRow[j])
            }
        }

        for i in (0..<data.count) {
            let currentRow = data[i]
            var newValues = [Double]()

            for (column, columnValue) in currentRow.enumerated() {
                let noOfBricks = itemNoOfBricks[column]
                let missingNoOfBricks = noOfBricks - columnValue

                let newColumnValues = Array(repeating: 1.0, count: columnValue) + Array(repeating: 0.0, count: missingNoOfBricks)
                newValues += newColumnValues
            }

            newData[i] = newValues
        }

        return newData
    }

    fileprivate func buildChartLabels(dates: [Date], timeUnit: TimeUnit) -> [String] {
        var labels = [String]()

        switch timeUnit {
        case .week:
            labels = dates.map { $0.dayName(ofStyle: .oneLetter)}

        case .month:
            labels = Array(repeating: " ", count: dates.count)
            var i = 0
            repeat {
                labels[i] = dates[i].toFormat(Constant.TimeFormat.day)
                i += 7
            } while i < dates.count

        case .year:
            labels = dates.map { $0.monthName(ofStyle: .oneLetter)}
        }

        return labels
    }

    fileprivate func setChartData(entries: [BarChartDataEntry]) {
        refreshGraphColor()

        let set = BarChartDataSet(entries: entries, label: "")
        set.drawValuesEnabled = false
        set.colors = buildChartColors()
        set.barBorderColor = .black
        set.barBorderWidth = 0.5

        let data = BarChartData(dataSet: set)
        data.barWidth = 1.0

        chart.fitBars = true
        chart.data = data
    }

    fileprivate func refreshGraphColor() {
        guard let reportItems = thisViewModel.reportItemsRelay.value else {
            itemIDs.removeAll()
            itemGraphColors.removeAll()
            return
        }

        itemGraphColors = Array(repeating: grayColor, count: itemNoOfBricks.count)
        itemIDs = reportItems.map { $0.id }
        currentColorIndex = 0
    }

    fileprivate func buildChartColors() -> [UIColor] {
        var chartColors = [UIColor]()
        for (index, thisItemColor) in itemGraphColors.enumerated() {
            let noOfBricks = itemNoOfBricks[index]
            chartColors += Array(repeating: thisItemColor, count: noOfBricks)
        }

        chartColors += [.white, .clear] // extra brick
        return chartColors
    }

    fileprivate func makeTapItemGesture() -> UITapGestureRecognizer {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event.bind { (event) in
            guard let dataRow = event.view as? HealthDataRow else { return }
            self.tapRow(dataRow: dataRow)

        }.disposed(by: disposeBag)
        return tapGesture
    }

    fileprivate func tapRow(dataRow: HealthDataRow) {
        guard let itemIndex = itemIDs.firstIndex(of: dataRow.key),
            let dataSet = self.chart.barData?.dataSets.first as? ChartBaseDataSet else { return }

        if !dataRow.selected {
            let color: UIColor!

            if removedGraphColors.isNotEmpty {
                color = removedGraphColors.removeLast()

            }  else {
                color = graphColorsSet[currentColorIndex]
                currentColorIndex += 1
            }

            if let index = itemGraphColors.firstIndex(of: color) {
                updateColorForItem(index: index, color: grayColor)

                if let healthDataRow = dataStackView.arrangedSubviews[index] as? HealthDataRow {
                    healthDataRow.toggleSelected(color: grayColor)
                }
            }

            updateColorForItem(index: itemIndex, color: color)
            dataRow.toggleSelected(color: color)
        } else {
            let currentItemColor = itemGraphColors[itemIndex]
            removedGraphColors.append(currentItemColor)
            updateColorForItem(index: itemIndex, color: grayColor)
            dataRow.toggleSelected(color: grayColor)

            // reset if all is unselected
            if itemGraphColors.filter({ $0 != grayColor }).count == 0 {
                removedGraphColors.removeAll()
                currentColorIndex = 0
            }
        }

        // Refresh chart
        dataSet.colors = buildChartColors()
        chart.setNeedsDisplay()
    }

    fileprivate func updateColorForItem(index: Int, color: UIColor) {
        itemGraphColors[index] = color
    }
}
