//
//  HealthScoreCollectionCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/8/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import SkeletonView

class HealthScoreCollectionCell: UICollectionViewCell {

    // MARK: - Properties
    lazy var healthView = makeHealthView()
    lazy var guideView = makeGuideView()
    lazy var guideDataView = makeGuideDataView()
    lazy var behaviorGuideView = makeBehaviorGuideView()

    // Behavior Guide View
    lazy var behaviorLabel = makeBehaviorLabel()

    // Data Guide View
    lazy var riskLabel = makeRiskLabel()
    lazy var confirmedCasesView = ScoreInfoView(scoreInfoType: .confirmedCases)
    lazy var reportedSymptomsView = ScoreInfoView(scoreInfoType: .reportedSymptoms)
    lazy var healthyBehaviorsView = ScoreInfoView(scoreInfoType: .healthyBehaviors)
    lazy var populationDensityView = ScoreInfoView(scoreInfoType: .populationDensity)
    let guideBoxInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)

    fileprivate let disposeBag = DisposeBag()

    override func layoutSubviews() {
        super.layoutSubviews()

        setupViews()
    }

    fileprivate func setupViews() {
        contentView.addSubview(healthView)
        contentView.addSubview(guideView)

        healthView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Size.dh(70))
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(HealthScoreTriangle.originalSize.height * HealthScoreTriangle.scale)
        }

        guideView.snp.makeConstraints { (make) in
            make.top.equalTo(healthView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
        }
    }

    func setData(areaProfile: AreaProfile?) {
        guard let areaProfile = areaProfile else {
            guideView.showAnimatedSkeleton()
            return
        }

        guideView.hideSkeleton()
        bindInfo(for: .confirmedCases, number: areaProfile.confirm, delta: areaProfile.confirmDelta)
        bindInfo(for: .reportedSymptoms, number: areaProfile.symptoms, delta: areaProfile.symptomsDelta)
        bindInfo(for: .healthyBehaviors, number: areaProfile.behavior, delta: areaProfile.behaviorDelta)
    }

    fileprivate func bindInfo(for scoreInfoType: ScoreInfoType, number: Int, delta: Int) {
        let formattedNumber = formatNumber(number)
        let formattedDelta = formatNumber(abs(delta))

        switch scoreInfoType {
        case .confirmedCases:
            confirmedCasesView.currentNumberLabel.setText(formattedNumber)
            confirmedCasesView.changeNumberLabel.setText(formattedDelta)
            switch true {
            case (delta > 0): confirmedCasesView.changeStatusArrow.image = R.image.redUpArrow()
            case (delta < 0): confirmedCasesView.changeStatusArrow.image = R.image.greenDownArrow()
            default:
                confirmedCasesView.changeStatusArrow.image = nil
                confirmedCasesView.changeNumberLabel.setText(nil)
            }

        case .reportedSymptoms:
            reportedSymptomsView.currentNumberLabel.setText(formattedNumber)
            reportedSymptomsView.changeNumberLabel.setText(formattedDelta)
            switch true {
            case (delta > 0): reportedSymptomsView.changeStatusArrow.image = R.image.redUpArrow()
            case (delta < 0): reportedSymptomsView.changeStatusArrow.image = R.image.greenDownArrow()
            default:
                reportedSymptomsView.changeStatusArrow.image = nil
                reportedSymptomsView.changeNumberLabel.setText(nil)
            }

        case .healthyBehaviors:
            healthyBehaviorsView.currentNumberLabel.setText(formattedNumber)
            healthyBehaviorsView.changeNumberLabel.setText(formattedDelta)
            switch true {
            case (delta > 0): healthyBehaviorsView.changeStatusArrow.image = R.image.greenUpArrow()
            case (delta < 0): healthyBehaviorsView.changeStatusArrow.image = R.image.redDownArrow()
            default:
                healthyBehaviorsView.changeStatusArrow.image = nil
                healthyBehaviorsView.changeNumberLabel.setText(nil)
            }

        case .populationDensity:
            break
        }
    }

    fileprivate func formatNumber(_ number: Int) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: number))
    }
}

extension HealthScoreCollectionCell {
    fileprivate func makeHealthView() -> UIView {
        let emptyTriangle = makeHealthScoreView(score: nil)

        let view = UIView()
        view.addSubview(emptyTriangle)
        emptyTriangle.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        return view
    }

    fileprivate func makeHealthScoreView(score: Int?) -> UIView {
        let healthScoreTriangle = HealthScoreTriangle(score: score)

        let appNameLabel = Label()
        appNameLabel.apply(text: Constant.appName.localizedUppercase,
                    font: R.font.domaineSansTextLight(size: 18),
                    themeStyle: .lightTextColor)

        let scoreLabel = Label()


        let view = UIView()
        view.addSubview(healthScoreTriangle)
        view.addSubview(appNameLabel)

        healthScoreTriangle.snp.makeConstraints { (make) in
            make.edges.centerX.equalToSuperview()
        }

        appNameLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(healthScoreTriangle).offset(-40 * HealthScoreTriangle.scale)
        }

        if let score = score {
            scoreLabel.apply(
                text: "\(score)",
                font: R.font.domaineSansTextLight(size: 64),
                themeStyle: .lightTextColor)

            view.addSubview(scoreLabel)
            scoreLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(appNameLabel.snp.top).offset(10)
                make.centerX.equalToSuperview()
            }
        }

        return view
    }

    fileprivate func makeGuideView() -> UIView {
        let view = UIView()
        view.addSubview(behaviorGuideView)
        view.addSubview(guideDataView)
        guideDataView.isSkeletonable = true

        guideDataView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        behaviorGuideView.snp.makeConstraints { (make) in
            make.edges.equalTo(guideDataView)
        }

        behaviorGuideView.isHidden = true
        view.isSkeletonable = true
        return view
    }

    fileprivate func makeBehaviorGuideView() -> UIView {
        return UIView()
    }

    fileprivate func makeGuideDataView() -> UIView {
        let row1 = makeScoreInfosRow(view1: confirmedCasesView, view2: reportedSymptomsView)
        let row2 = makeScoreInfosRow(view1: healthyBehaviorsView)

        let paddingView = UIView()
        paddingView.addSubview(row1)
        paddingView.addSubview(row2)

        row1.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        row2.snp.makeConstraints { (make) in
            make.top.equalTo(row1.snp.bottom).offset(Size.dh(15))
            make.leading.trailing.equalToSuperview()
        }

        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#2B2B2B")
        view.addSubview(paddingView)

        paddingView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(guideBoxInset)
        }

        return view
    }

    fileprivate func makeScoreInfosRow(view1: UIView, view2: UIView? = nil) -> UIView {
        let view = UIView()
        view.addSubview(view1)
        view1.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5).offset(Size.dw(15) / 2)
        }

        if let view2 = view2 {
            view.addSubview(view2)
            view2.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalTo(view1.snp.trailing).offset(Size.dw(15))
                make.width.equalTo(view1)
            }

        }
        return view
    }

    fileprivate func flip(fromView: UIView, toView: UIView) {
        UIView.transition(with: toView, duration: 0.5, options: .transitionFlipFromTop, animations: {
            fromView.isHidden = true
            toView.isHidden = false
        })
    }

    fileprivate func makeRiskLabel() -> Label {
        let label = Label()
        label.apply(font: R.font.domaineSansTextLight(size: 18), themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeBehaviorLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(font: R.font.atlasGroteskLight(size: 16), themeStyle: .lightTextColor)
        return label
    }
}
