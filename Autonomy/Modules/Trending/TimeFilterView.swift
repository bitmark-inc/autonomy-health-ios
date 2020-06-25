//
//  TimeFilterView.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/9/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftDate
import BetterSegmentedControl

class TimeFilterView: UIView {

    // MARK: - Properties
    fileprivate lazy var segmentView = makeSegmentView()
    fileprivate let disposeBag = DisposeBag()
    fileprivate lazy var previousPeriodButton = makePrevPeriodButton()
    fileprivate lazy var nextPeriodButton = makeNextPeriodButton()
    fileprivate lazy var periodLabel = makePeriodLabel()

    fileprivate let defaultStartDate = Date()
    var segmentDistances: [TimeUnit: Int] = [
        .week: 0, .month: 0, .year: 0
    ]
    lazy var startDate = defaultStartDate
    let timeInfoRelay = BehaviorRelay<(period: DatePeriod, unit: TimeUnit)?>(value: nil)

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        let navTimeView = LinearView(items: [
            (SeparateLine(height: 1), 0),
            (makePeriodView(), 0),
            (SeparateLine(height: 1), 0)
        ], bottomConstraint: true)

        addSubview(segmentView)
        addSubview(navTimeView)

        segmentView.snp.makeConstraints { (make) in
            make.width.equalTo(300)
            make.height.equalTo(30)
            make.centerX.top.equalToSuperview()
        }

        navTimeView.snp.makeConstraints { (make) in
            make.top.equalTo(segmentView.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview()
        }

        computeDatePeriod()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    fileprivate func computeDatePeriod() {
        guard let timeUnit = TimeUnit(index: segmentView.index),
            let distance = segmentDistances[timeUnit] else { return }

        nextPeriodButton.isEnabled = distance < 0 // disable next period to the future

        startDate = defaultStartDate.beginning(of: timeUnit.dateComponent)?
                                    .dateByAdding(distance, timeUnit.dateComponent)
                                    .date ?? Date()

        let endDate = startDate.end(of: timeUnit.dateComponent) ?? Date()
        let datePeriod = DatePeriod(startDate: startDate, endDate: endDate)
        timeInfoRelay.accept((datePeriod, timeUnit))
        periodLabel.setText(datePeriod.humanize(in: timeUnit).localizedUppercase)
    }

    func adjustSegment(isNext: Bool) {
        var index = segmentView.index
        if isNext {
            guard index != 2 else { return }
            index = index + 1
        } else {
            guard index != 0 else { return }
            index = index - 1
        }
        segmentView.setIndex(index)
    }

    fileprivate func adjustSegmentDistance(step: Int) { // step = -1 or +1
        guard let timeUnit = TimeUnit(index: segmentView.index) else { return }
        segmentDistances[timeUnit]! += step

        computeDatePeriod()
    }
}

extension TimeFilterView {
    fileprivate func makeSegmentView() -> BetterSegmentedControl {
        let labelSegments = LabelSegment.segments(
            withTitles: [
                R.string.localizable.week().localizedUppercase,
                R.string.localizable.month().localizedUppercase,
                R.string.localizable.year().localizedUppercase
            ],
            normalFont: R.font.domaineSansTextLight(size: 12),
            normalTextColor: UIColor.white,
            selectedFont: R.font.domaineSansTextLight(size: 12),
            selectedTextColor: UIColor.white
        )
        let control = BetterSegmentedControl(
            frame: CGRect(), segments: labelSegments,
            options: [.backgroundColor(.clear),
                      .indicatorViewBackgroundColor(themeService.attrs.sharkColor)])

        control.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] (_) in
                self?.computeDatePeriod()
            })
            .disposed(by: disposeBag)

        return control
    }

    fileprivate func makePeriodView() -> UIView {
        let view = UIView()
        view.addSubview(previousPeriodButton)
        view.addSubview(nextPeriodButton)
        view.addSubview(periodLabel)

        previousPeriodButton.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
        }

        periodLabel.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }

        nextPeriodButton.snp.makeConstraints { (make) in
            make.top.trailing.bottom.equalToSuperview()
        }

        return view
    }

    fileprivate func makePeriodLabel() -> Label {
        let label = Label()
        label.apply(font: R.font.atlasGroteskLight(size: 14),
                    themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makePrevPeriodButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.previousTimePeriod(), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 30)
        button.rx.tap.bind { [weak self] in
            self?.adjustSegmentDistance(step: -1)
        }.disposed(by: disposeBag)
        return button
    }

    fileprivate func makeNextPeriodButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.nextTimePeriod(), for: .normal)
        button.setImage(R.image.disabledNextPeriod(), for: .disabled)
        button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 30, bottom: 15, right: 0)
        button.rx.tap.bind { [weak self] in
            self?.adjustSegmentDistance(step: 1)
        }.disposed(by: disposeBag)
        return button
    }
}
