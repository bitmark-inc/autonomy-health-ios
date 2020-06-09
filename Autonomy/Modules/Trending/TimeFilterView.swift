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
import BetterSegmentedControl

class TimeFilterView: UIView {

    // MARK: - Properties
    fileprivate lazy var segmentView = makeSegmentView()
    fileprivate let disposeBag = DisposeBag()
    fileprivate lazy var previousPeriodButton = makePrevPeriodButton()
    fileprivate lazy var nextPeriodButton = makeNextPeriodButton()
    fileprivate lazy var periodLabel = makePeriodLabel()

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
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
        return button
    }

    fileprivate func makeNextPeriodButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.nextTimePeriod(), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 30, bottom: 15, right: 0)
        return button
    }
}
