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
    lazy var latestTimeLabel = makeLatestTimeLabel()
    lazy var numberButton = makeNumberButton()
    lazy var weightTextLabel = makeWeightTextLabel()
    lazy var weightSlider = makeWeightSlider()

    let scoreInfoType: ScoreInfoType!

    var weightValue: Float = 0 {
        didSet {
            weightTextLabel.setText("\(String(format: "%.2f", weightValue))")
        }
    }

    fileprivate let disposeBag = DisposeBag()

    init(for scoreInfoType: ScoreInfoType) {
        self.scoreInfoType = scoreInfoType
        super.init(frame: CGRect.zero)

        setupViews()
    }

    func setInitWeightValue(_ value: Float) {
        weightValue = value
        weightSlider.value = weightValue
    }

    fileprivate func setupViews() {
        var scoreText = ""
        var weightText = ""

        switch scoreInfoType {
        case .confirmedCases:
            scoreText = R.string.localizable.formulaCases()
            weightText = R.string.localizable.formulaCasesWeight()
        case .reportedSymptoms:
            scoreText = R.string.localizable.formulaSymptoms()
            weightText = R.string.localizable.formulaSymptomsWeight()
        case .healthyBehaviors:
            scoreText = R.string.localizable.formulaBehaviors()
            weightText = R.string.localizable.formulaBehaviorsWeight()
        default:
            break
        }

        let scoreView = makeRow(
            label: makeLeftLabel(text: scoreText),
            view: numberButton)

        let weightView = makeRow(
            label: makeLeftLabel(text: weightText),
            view: makeWeightBoxView())

        addSubview(latestTimeLabel)
        addSubview(scoreView)
        addSubview(weightView)

        latestTimeLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.trailing.equalTo(scoreView.snp.trailing).offset(-15)
        }

        scoreView.snp.makeConstraints { (make) in
            make.top.equalTo(latestTimeLabel.snp.bottom).offset(3)
            make.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }

        weightView.snp.makeConstraints { (make) in
            make.top.equalTo(scoreView.snp.bottom).offset(10)
            make.leading.bottom.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }

        latestTimeLabel.setText("Yesterday".localizedUppercase)
        numberButton.setTitle("200", for: .normal)
        setInitWeightValue(0.33)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup views
extension FormulaIndicatorView {
    fileprivate func makeLatestTimeLabel() -> Label {
        let label = Label()
        label.apply(font: R.font.atlasGroteskLight(size: 9),
                    themeStyle: .silverC4TextColor)
        return label
    }

    fileprivate func makeLeftLabel(text: String) -> Label {
        let text = text + " = "
        let label = Label()
        label.apply(text: text, font: R.font.ibmPlexMonoLight(size: 18), themeStyle: .blackTextColor)
        return label
    }

    fileprivate func makeNumberButton() -> UIButton {
        let button = RightIconButton(icon: R.image.crossCircleArrow())
        button.cornerRadius = 15
        button.apply(font: R.font.ibmPlexMonoLight(size: 18),
                     backgroundTheme: .blueRibbonColor)
        button.snp.makeConstraints { (make) in
            make.height.equalTo(30)
        }
        return button
    }

    fileprivate func makeWeightSlider() -> UISlider {
        let slider = UISlider()
        slider.setThumbImage(R.image.thumbSlider(), for: .normal)
        slider.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                let sliderValueText = String(format: "%.2f", slider.value)
                self.weightValue = Float(sliderValueText) ?? 0
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

    fileprivate func makeWeightBoxView() -> UIView {
        let view = UIView()
        view.addSubview(weightTextLabel)
        view.addSubview(weightSlider)
        view.cornerRadius = 15

        let contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)

        themeService.rx
            .bind({ $0.concordColor }, to: view.rx.backgroundColor)
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

        view.snp.makeConstraints { (make) in
            make.height.equalTo(30)
        }

        return view
    }

    fileprivate func makeRow(label: UILabel, view: UIView) -> UIView {
        let rowView = UIView()
        rowView.addSubview(label)
        rowView.addSubview(view)

        label.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
        }

        view.snp.makeConstraints { (make) in
            make.leading.equalTo(label.snp.trailing)
            make.top.trailing.bottom.equalToSuperview()
        }

        return rowView
    }
}
