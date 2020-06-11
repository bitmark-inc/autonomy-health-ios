//
//  YouHealthDetailsViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/5/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class YouHealthDetailsViewController: ViewController, BackNavigator {

    // MARK: - Properties
    fileprivate lazy var scrollView = makeScrollView()
    fileprivate lazy var backButton = makeLightBackItem()
    fileprivate lazy var groupsButton: UIView = {
        let groupView = ButtonGroupView(button1: backButton, button2: nil, hasGradient: false)
        groupView.apply(backgroundStyle: .codGrayBackground)
        return groupView
    }()

    fileprivate lazy var nameLabel = makeNameLabel()
    fileprivate lazy var healthTriangleView = makeHealthView()
    fileprivate lazy var youSymptomsView = makeYouSymptomsView()
    fileprivate lazy var youBehaviorsView = makeYouBehaviorsView()
    fileprivate lazy var neighborCasesView = makeNeighborCasesView()
    fileprivate lazy var neighborSymptomsView = makeNeighborSymptomsView()
    fileprivate lazy var neighborBehaviorsView = makeNeighborBehaviorsView()

    fileprivate lazy var thisViewModel: YouHealthDetailsViewModel = {
        return viewModel as! YouHealthDetailsViewModel
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func bindViewModel() {
        super.bindViewModel()

        thisViewModel.youAutonomyProfileRelay
            .filterNil()
            .subscribe(onNext: { [weak self] in
                self?.setData(autonomyProfile: $0)
            })
            .disposed(by: disposeBag)
    }

    fileprivate func setData(autonomyProfile: YouAutonomyProfile) {
        healthTriangleView.updateLayout(score: autonomyProfile.autonomyScore, animate: false)
        healthTriangleView.set(delta: autonomyProfile.autonomyScoreDelta)

        let you = autonomyProfile.individual
        youSymptomsView.setData(number: you.symptoms, delta: you.symptomsDelta, thingType: .bad)
        youBehaviorsView.setData(number: you.behaviors, delta: you.behaviorsDelta, thingType: .good)

        let neighbor = autonomyProfile.neighbor
        neighborCasesView.setData(number: neighbor.cases, delta: neighbor.casesDelta, thingType: .bad)
        neighborSymptomsView.setData(number: neighbor.symptoms, delta: neighbor.symptomsDelta, thingType: .bad)
        neighborBehaviorsView.setData(number: neighbor.behaviors, delta: neighbor.behaviorsDelta, thingType: .good)
    }

    override func setupViews() {
        super.setupViews()

        healthTriangleView.updateLayout(score: 28, animate: false)

        let paddingContentView = makePaddingContentView()

        scrollView.addSubview(paddingContentView)
        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
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
    }

    fileprivate func makePaddingContentView() -> UIView {
        return LinearView(items: [
            (nameLabel, 0),
            (healthTriangleView, 42),
            (HeaderView(header: R.string.localizable.you().localizedUppercase, lineWidth: Constant.lineHealthDataWidth), 45),
            (youSymptomsView, 30),
            (makeSeparateLine(), 14),
            (youBehaviorsView, 15),
            (HeaderView(header: R.string.localizable.neighborhood().localizedUppercase, lineWidth: Constant.lineHealthDataWidth), 38),
            (neighborCasesView, 30),
            (makeSeparateLine(), 14),
            (neighborSymptomsView, 15),
            (makeSeparateLine(), 14),
            (neighborBehaviorsView, 15)
        ], bottomConstraint: true)
    }
}

// MARK: - Navigator
extension YouHealthDetailsViewController {
    fileprivate func gotoAutonomyTrendingScreen() {
        let viewModel = AutonomyTrendingViewModel(autonomyObject: .individual)
        navigator.show(segue: .autonomyTrending(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoYouSymptomsTrendingScreen() {
        let viewModel = ItemTrendingViewModel(autonomyObject: .individual, reportItemObject: .symptoms)
        navigator.show(segue: .dataItemTrending(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoYouBehaviorsTrendingScreen() {
        let viewModel = ItemTrendingViewModel(autonomyObject: .individual, reportItemObject: .behaviors)
        navigator.show(segue: .dataItemTrending(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoNeighborSymptomsTrendingScreen() {
        let viewModel = ItemTrendingViewModel(autonomyObject: .neighbor, reportItemObject: .symptoms)
        navigator.show(segue: .dataItemTrending(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoNeighborBehaviorsTrendingScreen() {
        let viewModel = ItemTrendingViewModel(autonomyObject: .neighbor, reportItemObject: .behaviors)
        navigator.show(segue: .dataItemTrending(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoNeighborCasesTrendingScreen() {
        let viewModel = ItemTrendingViewModel(autonomyObject: .neighbor, reportItemObject: .cases)
        navigator.show(segue: .dataItemTrending(viewModel: viewModel), sender: self)
    }
}

// MARK: - Setup views
extension YouHealthDetailsViewController {
    fileprivate func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.contentInset = OurTheme.paddingInset
        return scrollView
    }

    fileprivate func makeNameLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.apply(text: R.string.localizable.you().localizedUppercase,
                    font: R.font.domaineSansTextLight(size: 18),
                    themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeHealthView() -> HealthScoreTriangle {
        let triangle = HealthScoreTriangle(score: nil)
        triangle.addGestureRecognizer(makeTriangleGestureRecognizer())
        return triangle
    }

    fileprivate func makeSeparateLine() -> UIView {
        return SeparateLine(height: 1, themeStyle: .mineShaftBackground)
    }

    fileprivate func makeTriangleGestureRecognizer() -> UITapGestureRecognizer {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.rx.event.bind { [weak self] (_) in
            self?.gotoAutonomyTrendingScreen()
        }.disposed(by: disposeBag)
        return tapGestureRecognizer
    }

    fileprivate func makeYouSymptomsView() -> HealthDataRow {
        let dataRow = HealthDataRow(info: R.string.localizable.symptoms().localizedUppercase)
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.rx.event.bind { [weak self] (_) in
            self?.gotoYouSymptomsTrendingScreen()
        }.disposed(by: disposeBag)

        dataRow.addGestureRecognizer(tapGestureRecognizer)
        return dataRow
    }

    fileprivate func makeYouBehaviorsView() -> HealthDataRow {
        let dataRow = HealthDataRow(info: R.string.localizable.healthyBehaviors().localizedUppercase)
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.rx.event.bind { [weak self] (_) in
            self?.gotoYouBehaviorsTrendingScreen()
        }.disposed(by: disposeBag)

        dataRow.addGestureRecognizer(tapGestureRecognizer)
        return dataRow
    }

    fileprivate func makeNeighborCasesView() -> HealthDataRow {
        let dataRow = HealthDataRow(info: R.string.localizable.activeCases().localizedUppercase)
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.rx.event.bind { [weak self] (_) in
            self?.gotoNeighborCasesTrendingScreen()
        }.disposed(by: disposeBag)

        dataRow.addGestureRecognizer(tapGestureRecognizer)
        return dataRow
    }

    fileprivate func makeNeighborSymptomsView() -> HealthDataRow {
        let dataRow = HealthDataRow(info: R.string.localizable.symptoms().localizedUppercase)
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.rx.event.bind { [weak self] (_) in
            self?.gotoNeighborSymptomsTrendingScreen()
        }.disposed(by: disposeBag)

        dataRow.addGestureRecognizer(tapGestureRecognizer)
        return dataRow
    }

    fileprivate func makeNeighborBehaviorsView() -> HealthDataRow {
        let dataRow = HealthDataRow(info: R.string.localizable.healthyBehaviors().localizedUppercase)
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.rx.event.bind { [weak self] (_) in
            self?.gotoNeighborBehaviorsTrendingScreen()
        }.disposed(by: disposeBag)

        dataRow.addGestureRecognizer(tapGestureRecognizer)
        return dataRow
    }
}
