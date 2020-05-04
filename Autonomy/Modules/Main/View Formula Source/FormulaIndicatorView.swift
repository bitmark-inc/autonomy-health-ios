//
//  FormulaIndicatorView.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/23/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FormulaIndicatorView: UIView {

    // MARK: - Properties
    lazy var scoreLabel = makeScoreLabel()
    lazy var weightTextLabel = makeWeightTextLabel()
    lazy var weightSlider = makeWeightSlider()

    let scoreInfoType: ScoreInfoType!

    let weightRelay = BehaviorRelay<Float>(value: 0)

    fileprivate let disposeBag = DisposeBag()

    init(for scoreInfoType: ScoreInfoType) {
        self.scoreInfoType = scoreInfoType
        super.init(frame: CGRect.zero)

        setupViews()
        bindViews()
    }

    func bindViews() {
        weightRelay
            .map { String(format: "%.2f", $0) }
            .bind(to: weightTextLabel.rx.text)
            .disposed(by: disposeBag)
    }

    func setData(score: Float) {
        setScore(score, in: scoreLabel)
    }

    func setInitWeightValue(_ value: Float) {
        weightRelay.accept(value)
        weightSlider.value = value
    }

    fileprivate func setupViews() {
        let weightView = RowView(items: [
            (makeLabel(text: leadingText), 0),
            (makeWeightBoxView(), 0),
            (makeLabel(text: ")"), 0)
        ], trailingConstraint: false)

        let topInfoLabel = makeTopInfoLabel(text: topInfoText)
        addSubview(scoreLabel)
        addSubview(weightView)
        addSubview(topInfoLabel)

        topInfoLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.trailing.equalTo(weightSlider).offset(-2)
        }

        weightView.snp.makeConstraints { (make) in
            make.top.equalTo(topInfoLabel.snp.bottom).offset(2)
            make.leading.trailing.bottom.equalToSuperview()
        }

        scoreLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalTo(weightTextLabel.snp.top).offset(2)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate lazy var leadingText: String = {
        switch scoreInfoType {
        case .confirmedCases:   return "(\(R.string.localizable.cases_score()) * "
        case .healthyBehaviors: return "(\(R.string.localizable.behaviors_score()) * "
        case .reportedSymptoms: return "(\(R.string.localizable.symptoms_score()) * "
        default:
            return ""
        }
    }()

    fileprivate lazy var topInfoText: String = {
        switch scoreInfoType {
        case .confirmedCases:   return R.string.localizable.casesWeight().localizedUppercase
        case .healthyBehaviors: return R.string.localizable.behaviorsWeight().localizedUppercase
        case .reportedSymptoms: return R.string.localizable.symptomsWeight().localizedUppercase
        default:
            return ""
        }
    }()
}

// MARK: - Setup views
extension FormulaIndicatorView {
    fileprivate func  makeScoreLabel() -> Label {
        let label = Label()
        label.font = R.font.ibmPlexMonoLight(size: 14)
        return label
    }

    fileprivate func makeLabel(text: String) -> Label {
        let label = Label()
        label.apply(
            text: text,
            font: R.font.ibmPlexMonoLight(size: Size.dw(18)),
            themeStyle: .blackTextColor)
        return label
    }

    fileprivate func makeWeightSlider() -> UISlider {
        let slider = UISlider()
        slider.setThumbImage(R.image.thumbSlider(), for: .normal)
        slider.rx.controlEvent(.valueChanged)
            .skip(1)
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                let sliderValueText = String(format: "%.2f", slider.value)
                self.weightRelay.accept(Float(sliderValueText) ?? 0)
            })
            .disposed(by: disposeBag)
        slider.snp.makeConstraints { (make) in
            make.width.equalTo(66)
        }
        return slider
    }

    fileprivate func makeWeightTextLabel() -> Label {
        let label = Label()
        label.apply(font: R.font.ibmPlexMonoLight(size: 18),
                    themeStyle: .lightTextColor)
        label.snp.makeConstraints { (make) in
            make.width.equalTo(46)
        }
        return label
    }

    fileprivate func makeTopInfoLabel(text: String) -> Label {
        let label = Label()
        label.apply(
            text: text,
            font: R.font.atlasGroteskLight(size: 9),
            themeStyle: .silverC4TextColor)
        return label
    }

    fileprivate func makeWeightBoxView() -> UIView {
        let weightSliderView = UIView()
        weightSliderView.addSubview(weightTextLabel)
        weightSliderView.addSubview(weightSlider)
        weightSliderView.cornerRadius = 15

        let contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)

        themeService.rx
            .bind({ $0.concordColor }, to: weightSliderView.rx.backgroundColor)
            .disposed(by: disposeBag)

        weightTextLabel.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
                .inset(contentEdgeInsets)
        }

        weightSlider.snp.makeConstraints { (make) in
            make.leading.equalTo(weightTextLabel.snp.trailing).offset(5)
            make.top.trailing.bottom.equalToSuperview()
                .inset(contentEdgeInsets)
        }

        weightSliderView.snp.makeConstraints { (make) in
            make.height.equalTo(30)
        }

        return weightSliderView
    }
}
