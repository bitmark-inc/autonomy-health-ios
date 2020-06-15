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

class ItemTrendingViewController: ViewController, BackNavigator {

    // MARK: - Properties
    fileprivate lazy var scrollView = makeScrollView()
    fileprivate lazy var headerScreen: UIView = {
        HeaderView(header: thisViewModel.reportItemObject.title)
    }()
    fileprivate lazy var timelineView = TimeFilterView()
    fileprivate lazy var dataStackView = makeDataStackView()
    fileprivate lazy var casesScoreDataView = HealthDataRow(info: R.string.localizable.casesScore().localizedUppercase, hasDot: true)
    fileprivate lazy var symptomsScoreDataView = HealthDataRow(info: R.string.localizable.symptomsScore().localizedUppercase, hasDot: true)
    fileprivate lazy var behaviorsScoreDataView = HealthDataRow(info: R.string.localizable.behaviorsScore().localizedUppercase, hasDot: true)
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
    }

    override func setupViews() {
        super.setupViews()

        // *** Setup subviews ***
        let paddingContentView = LinearView(
            items: [
                (headerScreen, 0),
                (timelineView, 10),
                (makeGraphsComingSoonView(), 0),
                (SeparateLine(height: 1), 0),
                (dataStackView, Size.dh(74))
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

            if index == reportItemsCount - 1 { // not add separateLine to last row
                return healthDataRow
            } else {
                return LinearView(
                    items: [(healthDataRow, 0), (SeparateLine(height: 1, themeStyle: .mineShaftBackground), 15)],
                    bottomConstraint: true)
            }
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

    fileprivate func makeDataStackView() -> UIStackView {
        return UIStackView(arrangedSubviews: [], axis: .vertical, spacing: 15)
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
}
