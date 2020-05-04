//
//  SymptomWeightView.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/4/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SymptomWeightView: UIView {

    // MARK: - Properties
    lazy var weightTextLabel = makeWeightTextLabel()
    lazy var weightSlider = makeWeightSlider()

    let symptom: Symptom!
    let weightRelay = BehaviorRelay<(String, Int)>(value: ("", 0))

    fileprivate let disposeBag = DisposeBag()

    init(for symptom: Symptom) {
        self.symptom = symptom
        super.init(frame: CGRect.zero)

        setupViews()
        bindViews()
    }

    func bindViews() {
        weightRelay
            .map { "\($0.1)" }
            .bind(to: weightTextLabel.rx.text)
            .disposed(by: disposeBag)
    }

    func setInitWeightValue(_ value: Int) {
        weightRelay.accept((symptom.id, value))
        weightSlider.value = Float(value)
    }

    fileprivate func setupViews() {
        let weightView = RowView(items: [
            (makeLabel(text: symptom.name), 0),
            (makeWeightBoxView(), 0)
        ], trailingConstraint: false)

        addSubview(weightView)

        weightView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup views
extension SymptomWeightView {
    fileprivate func makeLabel(text: String) -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(
            text: text + " = " ,
            font: R.font.ibmPlexMonoLight(size: Size.dw(18)),
            themeStyle: .blackTextColor)
        return label
    }

    fileprivate func makeWeightSlider() -> UISlider {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 3
        slider.setThumbImage(R.image.thumbSlider(), for: .normal)
        slider.rx.controlEvent(.valueChanged)
            .skip(1)
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.weightRelay.accept((self.symptom.id, Int(slider.value)))
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
            make.leading.equalTo(weightTextLabel.snp.trailing).offset(10)
            make.top.trailing.bottom.equalToSuperview()
                .inset(contentEdgeInsets)
        }

        weightSliderView.snp.makeConstraints { (make) in
            make.height.equalTo(30)
        }

        return weightSliderView
    }
}
