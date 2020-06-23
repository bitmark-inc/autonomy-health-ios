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
    fileprivate lazy var dataStackHeader = makeDataStackHeader()
    fileprivate lazy var dataStackView = makeDataStackView()
    fileprivate lazy var graphComingSoonLabel = makeGraphComingSoonLabel()
    fileprivate lazy var emptyDataLabel = makeEmptyDataLabel()

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

    var items = [String]()
    var itemGraphColors = [UIColor]()
    var currentColorIndex = 0 {
        didSet {
            if currentColorIndex >= 6 || currentColorIndex <= -1 {
                self.currentColorIndex = 0
            }
        }
    }

    let graphLabelTextColor = UIColor(hexString: "#BFBFBF")!
    let grayColor = UIColor(hexString: "#2B2B2B")!
    let graphColors = [
            UIColor(hexString: "#81CFFA"),
            UIColor(hexString: "#E3C878"),
            UIColor(hexString: "#E688A1"),
            UIColor(hexString: "#BBEAA6"),
            UIColor(hexString: "#ED9A73"),
            UIColor(hexString: "#E29AF4")
        ]

    override func bindViewModel() {
        super.bindViewModel()

        timelineView.datePeriodRelay
            .filterNil()
            .subscribe(onNext: { [weak self] in
                self?.thisViewModel.fetchTrending(in: $0)
            })
            .disposed(by: disposeBag)

        thisViewModel.reportItemsRelay
            .filterNil()
            .subscribe(onNext: { [weak self] (reportItems) in
                self?.rebuildScoreView(with: reportItems)
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
                (dataStackHeader, 30),
                (dataStackView, 0)
            ], bottomConstraint: true)

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
            emptyDataLabel.isHidden = false
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
        view.addSubview(emptyDataLabel)

        view.snp.makeConstraints { (make) in
            make.height.equalTo(255)
        }

        graphComingSoonLabel.snp.makeConstraints { (make) in
            make.centerX.centerY.width.equalToSuperview()
        }

        emptyDataLabel.snp.makeConstraints { (make) in
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

    fileprivate func makeEmptyDataLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        label.apply(text: R.string.phrase.trendingNoData(),
                    font: R.font.atlasGroteskLight(size: 18),
                    themeStyle: .concordColor, lineHeight: 1.25)
        return label
    }

    fileprivate func makeDataStackHeader() -> UIView {
        switch thisViewModel.reportItemObject {
        case .symptoms:
            return HealthDataHeaderView(
                R.string.localizable.symptom().localizedUppercase,
                R.string.localizable.days().localizedUppercase,
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
        view.addSubview(chart)

        label.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview()
        }

        chart.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom)
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
        chartView.highlightFullBarEnabled = false

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
                guard let self = self else { return }
                let timeUnit = self.timelineView.timeUnit

                guard let datePeriod = self.timelineView.datePeriodRelay.value else { return }
                let dataGroupByDay = GraphDataConverter.getDataGroupByDay(
                    with: reportItems,
                    timeUnit: timeUnit,
                    datePeriod: datePeriod)

                let sortedDataGroupByDay = dataGroupByDay.sorted(by: { $0.0 < $1.0 })

                var labels = [String]()
                var barChartDataEntries = [BarChartDataEntry]()

                for (index, dataByDay) in sortedDataGroupByDay.enumerated() {
                    labels.append(dataByDay.key.dayName(ofStyle: .oneLetter))

                    let barChartDataEntry = BarChartDataEntry(x: Double(index), yValues: dataByDay.value)
                    barChartDataEntries.append(barChartDataEntry)
                }

                self.chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
                self.setChartData(entries: barChartDataEntries)
            })
            .disposed(by: disposeBag)
    }

    fileprivate func setChartData(entries: [BarChartDataEntry]) {
        refreshGraphColor()

        let set = BarChartDataSet(entries: entries, label: "")
        set.drawValuesEnabled = false
        set.colors = itemGraphColors
        set.barBorderColor = .black
        set.barBorderWidth = 1.0

        let data = BarChartData(dataSet: set)
        data.barWidth = 1.0
        chart.fitBars = true
        chart.data = data
    }

    fileprivate func refreshGraphColor() {
        guard let reportItems = thisViewModel.reportItemsRelay.value else {
            items.removeAll()
            itemGraphColors.removeAll()
            return
        }

        items = reportItems.map { $0.name }
        itemGraphColors = Array(repeating: grayColor, count: reportItems.count)
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
        guard let itemIndex = items.firstIndex(of: dataRow.key),
            let dataSet = self.chart.barData?.dataSets.first as? ChartBaseDataSet else { return }

        if !dataRow.selected {
            let color = graphColors[currentColorIndex]
            currentColorIndex += 1

            if let index = itemGraphColors.firstIndex(of: color) {
                itemGraphColors[index] = grayColor

                if let healthDataRow = dataStackView.arrangedSubviews[index] as? HealthDataRow {
                    healthDataRow.toggleSelected(color: grayColor)
                }
            }

            itemGraphColors[itemIndex] = color
            dataRow.toggleSelected(color: color)
        }

        // Refresh chart
        dataSet.colors = itemGraphColors
        chart.setNeedsDisplay()
    }
}
