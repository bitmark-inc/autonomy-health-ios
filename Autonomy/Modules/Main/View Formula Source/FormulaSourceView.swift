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
    lazy var scoreLabel = makeScoreLabel()

    lazy var caseFormulaIndicatorView = FormulaIndicatorView(for: .confirmedCases)
    lazy var symptomFormulaIndicatorView = FormulaIndicatorView(for: .reportedSymptoms)
    lazy var behaviorFormulaIndicatorView = FormulaIndicatorView(for: .healthyBehaviors)

    // Confirmed Cases Score
    lazy var confirmedCasesFormulaView = makeConfirmedCasesFormulaView()
    fileprivate let caseElementHeight: CGFloat = 42
    lazy var yesterdayCasesDataView = FigDataView(
        topInfo: R.string.localizable.yesterday().localizedUppercase,
        height: caseElementHeight)
    lazy var todayCasesDataView = FigDataView(
        topInfo: R.string.localizable.today().localizedUppercase,
        height: caseElementHeight)

    // Reported Behaviors Score
    fileprivate let behaviorElementHeight: CGFloat = 60
    lazy var behaviorsFormulaView = makeBehaviorsFormulaView()
    lazy var behaviorsTotalDataView = FigDataView(
        topInfo: R.string.localizable.behaviorsTotal().localizedUppercase,
        height: behaviorElementHeight)
    lazy var behaviorsTotalPeopleDataView = FigDataView(
        topInfo: R.string.localizable.totalPeople().localizedUppercase,
        height: behaviorElementHeight)
    lazy var behaviorsMaxScorePerPersonDataView = FigDataView(
        topInfo: R.string.localizable.maxScorePerPerson().localizedUppercase,
        height: behaviorElementHeight)

    // Reported Symptoms Score
    fileprivate let symptomElementHeight: CGFloat = 60
    lazy var symptomsFormulaView = makeSymptomsFormulaView()
    lazy var symptomsTotalDataView = FigDataView(
        topInfo: R.string.localizable.symptomsTotal().localizedUppercase,
        height: symptomElementHeight)
    lazy var symptomsTotalPeopleDataView = FigDataView(
        topInfo: R.string.localizable.totalPeople().localizedUppercase,
        height: symptomElementHeight)
    lazy var symptomsMaxScorePerPersonDataView = FigDataView(
        topInfo: R.string.localizable.maxScorePerPerson().localizedUppercase,
        height: symptomElementHeight)

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

    override func layoutSubviews() {
        super.layoutSubviews()

        confirmedCasesFormulaView.rearrangeViews()
        behaviorsFormulaView.rearrangeViews()
        symptomsFormulaView.rearrangeViews()
    }

    // MARK: - Setup views
    fileprivate func setupViews() {
        backgroundColor = .clear

        let formulaView = LinearView(
            items: [
                (scoreLabel, 20),
                (makeBoldLabel(text: "autonomy ="), 0),
                (caseFormulaIndicatorView, 0),
                (makeLabel("+"), 0),
                (behaviorFormulaIndicatorView, 0),
                (makeLabel("+"), 0),
                (symptomFormulaIndicatorView, 0),
                (makeConfirmedCasesGuideView(), 45),
                (makeBehaviorsGuideView(), 40),
                (makeSymptomsGuideView(), 40)
            ],
            bottomConstraint: true)

        addSubview(formulaView)
        formulaView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 14, left: 15, bottom: 0, right: 15))
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

    fileprivate func makeBoldLabel(text: String) -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: text,
                    font: R.font.ibmPlexMonoBold(size: 18),
                    themeStyle: .blackTextColor)
        return label
    }

    fileprivate func makeConfirmedCasesGuideView() -> UIView {
        let titleLabel = makeBoldLabel(text: R.string.localizable.confirmedCasesScore())

        return LinearView(
            items: [
                (titleLabel, 0),
                (confirmedCasesFormulaView, 0)],
            bottomConstraint: true)
    }

    fileprivate func makeBehaviorsGuideView() -> UIView {
        let titleLabel = makeBoldLabel(text: R.string.localizable.reportedBehaviorsScore())
        let descriptionLabel = makeLabel(R.string.localizable.reportedBehaviorsScoreDesc())

        return LinearView(
            items: [
                (titleLabel, 0),
                (descriptionLabel, 15),
                (behaviorsFormulaView, -10)
            ],
            bottomConstraint: true)
    }

    fileprivate func makeSymptomsGuideView() -> UIView {
        let titleLabel = makeBoldLabel(text: R.string.localizable.reportedSymptomsScore())
        let descriptionLabel = makeLabel(R.string.localizable.reportedSymptomsScoreDesc())

        return LinearView(
            items: [
                (titleLabel, 0),
                (descriptionLabel, 15),
                (symptomsFormulaView, -10)],
            bottomConstraint: true)
    }

    fileprivate func makeConfirmedCasesFormulaView() -> FormulaView {
        let formulaView = FormulaView()
        formulaView.addPart(FigLabel(R.string.localizable.cases_score()))
        formulaView.addPart(FigLabel("="))
        formulaView.addPart(FigLabel("100 -"))
        formulaView.addPart(FigLabel("5 *"))
        formulaView.addPart(FigLabel("("))
        formulaView.addPart(yesterdayCasesDataView)
        formulaView.addPart(FigLabel("-"))
        formulaView.addPart(todayCasesDataView)
        formulaView.addPart(FigLabel(")"))
        return formulaView
    }

    fileprivate func makeBehaviorsFormulaView() -> FormulaView {
        let formulaView = FormulaView()
        formulaView.addPart(FigLabel(R.string.localizable.behaviors_score(), height: behaviorElementHeight))
        formulaView.addPart(FigLabel("=", height: behaviorElementHeight))
        formulaView.addPart(FigLabel("100 *", height: behaviorElementHeight))
        formulaView.addPart(FigLabel("(", height: behaviorElementHeight))
        formulaView.addPart(behaviorsTotalDataView)
        formulaView.addPart(FigLabel("/", height: behaviorElementHeight))
        formulaView.addPart(behaviorsTotalPeopleDataView)
        formulaView.addPart(FigLabel("*", height: behaviorElementHeight))
        formulaView.addPart(behaviorsMaxScorePerPersonDataView)
        formulaView.addPart(FigLabel("))", height: behaviorElementHeight))
        return formulaView
    }

    fileprivate func makeSymptomsFormulaView() -> FormulaView {
        let formulaView = FormulaView()
        formulaView.addPart(FigLabel(R.string.localizable.symptoms_score(), height: symptomElementHeight))
        formulaView.addPart(FigLabel("=", height: symptomElementHeight))
        formulaView.addPart(FigLabel("100 -", height: symptomElementHeight))
        formulaView.addPart(FigLabel("(100 *", height: symptomElementHeight))
        formulaView.addPart(FigLabel("(", height: symptomElementHeight))
        formulaView.addPart(symptomsTotalDataView)
        formulaView.addPart(FigLabel("/", height: symptomElementHeight))
        formulaView.addPart(symptomsTotalPeopleDataView)
        formulaView.addPart(FigLabel("*", height: symptomElementHeight))
        formulaView.addPart(symptomsMaxScorePerPersonDataView)
        formulaView.addPart(FigLabel(")))", height: symptomElementHeight))
        return formulaView
    }

    fileprivate func makeLabel(_ text: String) -> UILabel {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: text,
                    font: R.font.ibmPlexMonoLight(size: 18),
                    themeStyle: .blackTextColor)
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

    fileprivate func makeNumberButton() -> UIButton {
        let button = RightIconButton(icon: R.image.crossCircleArrow())
        button.cornerRadius = 15
        button.apply(font: R.font.ibmPlexMonoLight(size: 18),
                     backgroundTheme: .blueRibbonColor)
        button.snp.makeConstraints { (make) in
            make.height.equalTo(30)
        }

        button.rx.tap.bind {
            print("go to click")
        }.disposed(by: disposeBag)
        return button
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
