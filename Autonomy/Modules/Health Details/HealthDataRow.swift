//
//  HealthDataRow.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/5/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit

class HealthDataRow: UIView {

    // MARK: - Properties
    fileprivate let info: String!
    fileprivate let hasDot: Bool!

    fileprivate lazy var infoLabel = makeInfoLabel()
    fileprivate lazy var numberLabel = makeNumberLabel()
    fileprivate lazy var deltaView = makeDeltaView()
    fileprivate lazy var deltaImageView = makeDeltaImageView()
    fileprivate lazy var numberInfoLabel = makeNumberInfoLabel()

    init(info: String, hasDot: Bool = false) {
        self.info = info
        self.hasDot = hasDot
        super.init(frame: CGRect.zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupViews() {
        addSubview(infoLabel)
        addSubview(numberLabel)
        addSubview(deltaView)

        if hasDot {
            let dotImageView = ImageView(image: R.image.lineDot())
            addSubview(dotImageView)
            dotImageView.snp.makeConstraints { (make) in
                make.leading.centerY.equalToSuperview()
                make.width.height.equalTo(15)
            }

            infoLabel.snp.makeConstraints { (make) in
                make.leading.equalTo(dotImageView.snp.trailing).offset(15)
            }
        } else {
            infoLabel.snp.makeConstraints { (make) in
                make.leading.equalToSuperview()
            }
        }

        infoLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(numberLabel.snp.leading)
        }

        numberLabel.snp.makeConstraints { (make) in
            make.width.equalTo(70)
            make.top.bottom.equalTo(infoLabel)
        }

        deltaView.snp.makeConstraints { (make) in
            make.width.equalTo(Size.dw(105))
            make.leading.equalTo(numberLabel.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
        }
    }

    func setData(autonomyReportItem reportItem: ReportItem) {
        let delta = reportItem.changeRate

        if let value = reportItem.value {
            numberLabel.setText(value.roundInt.polish)
            numberLabel.textColor = HealthRisk(from: value)?.color
        } else {
            numberLabel.setText("--")
            numberLabel.textColor = .white
        }

        numberInfoLabel.setText("\(abs(delta).formatPercent)%")

        buildDeltaView(delta: delta, thingType: .good)
    }

    func setData(reportItem: ReportItem, thingType: ThingType) {
        let delta = reportItem.changeRate

        numberLabel.setText(reportItem.value?.roundInt.polish ?? "--")
        numberInfoLabel.setText("\(abs(delta).formatPercent)%")

        buildDeltaView(delta: delta, thingType: thingType)
    }

    func setData(number: Int, delta: Float, thingType: ThingType) {
        numberLabel.setText("\(number.polish)")
        numberInfoLabel.setText("\(abs(delta).formatPercent)%")

        buildDeltaView(delta: delta, thingType: thingType)
    }

    func setData(resourceReportItem: ResourceReportItem) {
        let score = resourceReportItem.score

        if score == 0 {
            numberLabel.setText("--")
            numberLabel.textColor = .white
        } else {
            numberLabel.setText(score.formatRatingScore)
            numberLabel.textColor = Rating(from: score).color
        }

        numberInfoLabel.setText(resourceReportItem.ratings.simple)
        numberInfoLabel.textColor = .white
    }

    fileprivate func buildDeltaView(delta: Float, thingType: ThingType) {
        switch (delta, thingType) {
        case _ where delta > 0 && thingType == .good:
            deltaImageView.image = R.image.greenUpArrow()
            numberInfoLabel.textColor = Constant.positiveColor

        case _ where delta > 0 && thingType == .bad:
            deltaImageView.image = R.image.redUpArrow()
            numberInfoLabel.textColor = Constant.negativeColor

        case _ where delta < 0 && thingType == .good:
            deltaImageView.image = R.image.redDownArrow()
            numberInfoLabel.textColor = Constant.negativeColor

        case _ where delta < 0 && thingType == .bad:
            deltaImageView.image = R.image.greenDownArrow()
            numberInfoLabel.textColor = Constant.positiveColor

        default:
            deltaImageView.image = nil
            numberInfoLabel.textColor = UIColor(hexString: "#828180")
        }
    }
}

extension HealthDataRow {
    fileprivate func makeInfoLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byWordWrapping
        label.apply(text: info, font: R.font.atlasGroteskLight(size: 14),
                    themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeNumberLabel() -> Label {
        let label = Label()
        label.textAlignment = .right
        label.font = R.font.ibmPlexMonoLight(size: 14)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }

    fileprivate func makeDeltaView() -> UIView {
        let view = UIView()
        view.addSubview(deltaImageView)
        view.addSubview(numberInfoLabel)

        numberInfoLabel.snp.makeConstraints { (make) in
            make.top.trailing.bottom.equalToSuperview()
        }

        deltaImageView.snp.makeConstraints { (make) in
            make.trailing.equalTo(numberInfoLabel.snp.leading).offset(-3)
            make.centerY.equalToSuperview()
        }

        return view
    }

    fileprivate func makeDeltaImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(10)
        }
        return imageView
    }

    fileprivate func makeNumberInfoLabel() -> Label { // delta / rating
        let label = Label()
        label.font = R.font.ibmPlexMonoLight(size: 14)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }
}
