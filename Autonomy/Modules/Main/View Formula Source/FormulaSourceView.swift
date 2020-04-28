//
//  FormulaSourceView.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/23/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftRichString

class FormulaSourceView: UIView {

    // MARK: - Properties
    lazy var caseFormulaIndicatorView = FormulaIndicatorView(for: .confirmedCases)
    lazy var symptomFormulaIndicatorView = FormulaIndicatorView(for: .reportedSymptoms)
    lazy var behaviorFormulaIndicatorView = FormulaIndicatorView(for: .healthyBehaviors)
    lazy var scoreLabel = makeScoreLabel()
    lazy var resetButton = makeResetButton()
    lazy var buttonGroupsView = makeButtonGroupsView()
    let disposeBag = DisposeBag()

    // - Indicator
    let casesWeightRelay = BehaviorRelay<Float>(value: 0.33)
    let scoreRelay = BehaviorRelay<Int>(value: 0)

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        bindToCalculate()
    }

    // MARK: - Setup views
    fileprivate func setupViews() {
        backgroundColor = .clear

        let formulaView = LinearView(
            items: [
                (caseFormulaIndicatorView, 0),
                (symptomFormulaIndicatorView, 15),
                (behaviorFormulaIndicatorView, 15),
                (scoreLabel, 20),
                (makeFormulaLabel(), 0),
                (buttonGroupsView, 30)],
            bottomConstraint: true)

        addSubview(formulaView)
        formulaView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 14, left: 15, bottom: 58, right: 15))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Formula Calculator
extension FormulaSourceView {
    func bindToCalculate() {
        let casesWeightRelay = caseFormulaIndicatorView.weightRelay.share()

        BehaviorRelay.combineLatest(casesWeightRelay, casesWeightRelay)
            .subscribe(onNext: { [weak self] (casesWeight, behaviorsWeight) in
                guard let self = self else { return }
                let score = casesWeight * 100
                self.scoreRelay.accept(Int(score))
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Setup views
extension FormulaSourceView {
    fileprivate func makeScoreLabel() -> Label {
        let label = Label()
        label.font = R.font.ibmPlexMono(size: 24)
        return label
    }

    fileprivate func makeFormulaLabel() -> Label {
        let styleGroup: StyleXML = {
            let style = Style {
                $0.font = R.font.ibmPlexMono(size: 18)
                $0.color = themeService.attrs.blackTextColor
            }

            let highlight = Style {
                $0.font = R.font.ibmPlexMonoMedium(size: 18)
            }

            return StyleXML(base: style, ["b": highlight])
        }()

        let label = Label()
        label.numberOfLines = 0
        label.attributedText = R.string.localizable.formula().set(style: styleGroup)
        return label
    }

    fileprivate func makeButtonGroupsView() -> UIView {
        let view = UIView()
        view.addSubview(resetButton)
        resetButton.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
        }
        return view
    }

    fileprivate func makeResetButton() -> UIButton {
        let button = RightIconButton(
            title: R.string.localizable.reset().localizedUppercase,
            icon: R.image.resetIcon()!)
        button.snp.makeConstraints { (make) in
            make.height.equalTo(30)
        }
        button.cornerRadius = 15

        themeService.rx
            .bind( { $0.silverColor }, to: button.rx.backgroundColor)
            .disposed(by: disposeBag)

        return button
    }
}
