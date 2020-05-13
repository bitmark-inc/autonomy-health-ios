//
//  ColumnDataView.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/13/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit

class ColumnDataView: UIView {

    enum ThingType {
        case good
        case bad
    }

    // MARK: - Properties
    fileprivate let title: String!
    fileprivate let thingType: ThingType
    fileprivate lazy var titleLabel = makeTitleLabel()
    fileprivate lazy var numberLabel = makeNumberLabel()
    fileprivate lazy var changeStatusArrow = makeChangeStatusArrow()
    fileprivate lazy var deltaLabel = makeDeltaLabel()


    init(title: String, _ thingType: ThingType) {
        self.title = title
        self.thingType = thingType
        super.init(frame: .zero)

        let contentView = LinearView(
            items: [
                (titleLabel, 0),
                (numberLabel, 5),
                (makeDeltaView(), 5),
                (makeFromYesterdayLabel(), 8)
        ], bottomConstraint: true)

        addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    func setData(number: Float?, delta: Float?) {
        let number = number ?? 0
        let delta = delta ?? 0

        numberLabel.setText(number.simple)
        changeStatusArrow.image = R.image.redDownArrowReported()
        deltaLabel.setText("\(abs(delta).formatPercent)%")

        switch (delta, thingType) {
        case _ where delta > 0 && thingType == .good:
            changeStatusArrow.image = R.image.greenUpArrowReported()
            deltaLabel.textColor = Constant.positiveColor

        case _ where delta > 0 && thingType == .bad:
            changeStatusArrow.image = R.image.redUpArrowReported()
            deltaLabel.textColor = Constant.negativeColor

        case _ where delta < 0 && thingType == .good:
            changeStatusArrow.image = R.image.redDownArrowReported()
            deltaLabel.textColor = Constant.negativeColor

        case _ where delta < 0 && thingType == .bad:
            changeStatusArrow.image = R.image.greenDownArrowReported()
            deltaLabel.textColor = Constant.positiveColor

        default:
            changeStatusArrow.image = nil
            deltaLabel.textColor = .white
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func makeTitleLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(
            text: title,
            font: R.font.atlasGroteskLight(size: 12),
            themeStyle: .lightTextColor, lineHeight: 1.2)
        return label
    }

    fileprivate func makeDeltaView() -> UIView {
        return RowView(items: [
            (changeStatusArrow, 0),
            (deltaLabel, 3)
        ], trailingConstraint: false)
    }

    fileprivate func makeNumberLabel() -> Label {
        let label = Label()
        label.adjustsFontSizeToFitWidth = true
        label.apply(font: R.font.ibmPlexMonoLight(size: 96), themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeChangeStatusArrow() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    fileprivate func makeDeltaLabel() -> Label {
        let label = Label()
        label.font = R.font.ibmPlexMonoLight(size: 18)
        return label
    }

    fileprivate func makeFromYesterdayLabel() -> Label {
        let label = Label()
        label.apply(text: R.string.localizable.fromYesterday().localizedUppercase,
                    font: R.font.atlasGroteskLight(size: 10),
                    themeStyle: .silverColor)
        return label
    }
}
