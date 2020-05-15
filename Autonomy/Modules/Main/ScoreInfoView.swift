//
//  ScoreInfoView.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/9/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit

class ScoreInfoView: UIView {

    // MARK: - Properties
    lazy var titleLabel = makeTitleLabel()
    lazy var currentNumberLabel = makeCurrentNumberLabel()
    lazy var changeStatusArrow = makeChangeStatusArrow()
    lazy var changeNumberLabel = makeChangeNumberLabel()

    let scoreInfoType: ScoreInfoType!
    var titleFontSize: CGFloat {
        switch UIScreen.main.bounds.size.width {
        case let x where x <= 320:
            return 10
        default:
            return 12
        }
    }

    init(scoreInfoType: ScoreInfoType) {
        self.scoreInfoType = scoreInfoType
        super.init(frame: CGRect.zero)

        setupViews()
        titleLabel.setText(getTitle())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupViews() {
        let dataView = UIView()
        dataView.addSubview(currentNumberLabel)
        dataView.addSubview(changeStatusArrow)
        dataView.addSubview(changeNumberLabel)

        currentNumberLabel.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
                .inset(UIEdgeInsets(top: -10, left: 0, bottom: -5, right: 0))
        }

        changeStatusArrow.snp.makeConstraints { (make) in
            make.leading.equalTo(currentNumberLabel.snp.trailing).offset(4)
            make.top.equalToSuperview()
            make.width.height.equalTo(12)
        }

        changeNumberLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(changeStatusArrow.snp.trailing).offset(4)
            make.top.equalTo(changeStatusArrow).offset(-4)
        }

        addSubview(titleLabel)
        addSubview(dataView)

        titleLabel.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        dataView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    fileprivate func getTitle() -> String {
        switch scoreInfoType {
        case .confirmedCases:    return R.string.localizable.confirmedInfections().localizedUppercase
        case .reportedSymptoms:  return R.string.localizable.symptoms().localizedUppercase
        case .healthyBehaviors:  return R.string.localizable.healthyBehaviors().localizedUppercase
        case .populationDensity: return R.string.localizable.atRistPopulation().localizedUppercase
        case .none:
            return ""
        }
    }
}

enum ScoreInfoType {
    case confirmedCases
    case reportedSymptoms
    case healthyBehaviors
    case populationDensity
}

extension ScoreInfoView {
    fileprivate func makeTitleLabel() -> Label {
        let label = Label()
        label.apply(font: R.font.atlasGroteskLight(size: titleFontSize),
                    themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeCurrentNumberLabel() -> Label {
        let label = Label()
        label.apply(font: R.font.ibmPlexMonoMedium(size: 24),
                    themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeChangeStatusArrow() -> UIImageView {
        return UIImageView()
    }

    fileprivate func makeChangeNumberLabel() -> Label {
        let label = Label()
        label.font = R.font.ibmPlexMonoLight(size: 14)
        return label
    }
}
