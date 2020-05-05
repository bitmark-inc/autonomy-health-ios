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
    lazy var confirmScoreLabel = makeIndicatorScoreLabel()
    lazy var yesterdayCasesDataView = makeFigDataView(
        topInfo: R.string.localizable.yesterday().localizedUppercase,
        height: caseElementHeight)
    lazy var todayCasesDataView = makeFigDataView(
        topInfo: R.string.localizable.today().localizedUppercase,
        height: caseElementHeight)

    // Reported Behaviors Score
    fileprivate let behaviorElementHeight: CGFloat = 60
    fileprivate lazy var behaviorsScoreLabel = makeIndicatorScoreLabel()
    fileprivate lazy var behaviorsFormulaView = makeBehaviorsFormulaView()
    fileprivate lazy var behaviorsTotalDataView = makeFigDataView(
        topInfo: R.string.localizable.behaviorsTotal().localizedUppercase,
        height: behaviorElementHeight)
    fileprivate lazy var behaviorsTotalPeopleDataView = makeFigDataView(
        topInfo: R.string.localizable.totalPeople().localizedUppercase,
        height: behaviorElementHeight)
    fileprivate lazy var behaviorsMaxScorePerPersonDataView = makeFigDataView(
        topInfo: R.string.localizable.maxScorePerPerson().localizedUppercase,
        height: behaviorElementHeight)
    fileprivate lazy var behaviorsTotalCustomizedDataView = makeFigDataView(
        topInfo: R.string.localizable.totalCustomized().localizedUppercase,
        height: behaviorElementHeight)

    // Reported Symptoms Score
    fileprivate let symptomElementHeight: CGFloat = 60
    fileprivate lazy var symptomsScoreLabel = makeIndicatorScoreLabel()
    fileprivate lazy var symptomsFormulaView = makeSymptomsFormulaView()
    fileprivate lazy var symptomWeightsStackView = makeSymptomWeightsStackView()
    fileprivate lazy var symptomsTotalWeightDataView = makeFigDataView(
        topInfo: R.string.localizable.totalWeight().localizedUppercase,
        height: symptomElementHeight)
    fileprivate lazy var symptomsTotalPeopleDataView = makeFigDataView(
        topInfo: R.string.localizable.totalPeople().localizedUppercase,
        height: symptomElementHeight)
    fileprivate lazy var symptomsMaxWeightDataView = makeFigDataView(
        topInfo: R.string.localizable.maxWeight().localizedUppercase,
        height: symptomElementHeight)
    fileprivate lazy var symptomsCustomizedWeightDataView = makeFigDataView(
        topInfo: R.string.localizable.customizedWeight().localizedUppercase,
        height: symptomElementHeight)

    fileprivate lazy var resetButton = makeResetButton()
    fileprivate lazy var buttonGroupsView = makeButtonGroupsView()

    fileprivate let symptomWeightsRelay = BehaviorRelay<[(String, Int)]>(value: [])
    fileprivate var localSymptomWeightsDisposable: Disposable?
    fileprivate var calculatorDisposable: Disposable?

    weak var delegate: ScoreSourceDelegate?
    fileprivate let disposeBag = DisposeBag()

    // - Indicator
    let scoreRelay = BehaviorRelay<Float>(value: 0)
    var areaProfile: AreaProfile?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()

        bindFormulaWeightEvents()
    }

    deinit {
        calculatorDisposable?.dispose()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        confirmedCasesFormulaView.rearrangeViews()
        behaviorsFormulaView.rearrangeViews()
        symptomsFormulaView.rearrangeViews()
    }

    // MARK: - Handles Data
    func setData(areaProfile: AreaProfile) {
        self.areaProfile = areaProfile

        // Global Score
        scoreLabel.setText("\(areaProfile.displayScore)")
        scoreLabel.textColor = HealthRisk(from: areaProfile.displayScore)?.color

        ///
        let confirmDetails = areaProfile.details.confirm
        let symptomsDetails = areaProfile.details.symptoms
        let behaviorsDetails = areaProfile.details.behaviors

        // Weight Score
        caseFormulaIndicatorView.setData(score: confirmDetails.score)
        symptomFormulaIndicatorView.setData(score: symptomsDetails.score)
        behaviorFormulaIndicatorView.setData(score: behaviorsDetails.score)

        // -- Confirmed Formula
        setScore(confirmDetails.score, in: confirmScoreLabel)
        yesterdayCasesDataView.setValue(confirmDetails.yesterday)
        todayCasesDataView.setValue(confirmDetails.today)

        // -- Behaviors Formula
        setScore(behaviorsDetails.score, in: behaviorsScoreLabel)
        behaviorsTotalDataView.setValue(behaviorsDetails.behaviorTotal)
        behaviorsTotalPeopleDataView.setValue(behaviorsDetails.totalPeople)
        behaviorsMaxScorePerPersonDataView.setValue(behaviorsDetails.maxScorePerPerson)
        behaviorsTotalCustomizedDataView.setValue(behaviorsDetails.behaviorCustomizedTotal)

        // -- Symptoms Formula
        setScore(symptomsDetails.score, in: symptomsScoreLabel)
        symptomsTotalWeightDataView.setValue(symptomsDetails.totalWeight)
        symptomsTotalPeopleDataView.setValue(symptomsDetails.totalPeople)
        symptomsMaxWeightDataView.setValue(symptomsDetails.maxWeight)
        symptomsCustomizedWeightDataView.setValue(symptomsDetails.customizedWeight)
    }

    func setRemoteData(coefficient: Coefficient) {
        caseFormulaIndicatorView.setInitWeightValue(coefficient.confirms)
        behaviorFormulaIndicatorView.setInitWeightValue(coefficient.behaviors)
        symptomFormulaIndicatorView.setInitWeightValue(coefficient.symptoms)

        buildSymptomWeightsStackView(with: coefficient.symptomWeights)
    }

    var didObserve: Bool = false
    fileprivate func bindFormulaWeightEvents() {
        // bind Data
        FormulaSupporter.coefficientRelay
            .filterNil()
            .filter { [weak self] in
                guard let self = self else { return false }
                return $0.actor == nil || $0.actor != self
            }
            .map { $0.v }
            .subscribe(onNext: { [weak self] (coefficient) in
                guard let self = self else { return }
                self.isUserInteractionEnabled = true
                self.setRemoteData(coefficient: coefficient)

                if !self.didObserve { // only observe after setting remote data the first time
                    self.observeElementEventsAndCalculateScore()
                    self.didObserve = true
                }

            })
            .disposed(by: disposeBag)

        // Calculate
        FormulaSupporter.coefficientRelay
            .filterNil()
            .map { $0.v }
            .subscribe(onNext: { [weak self] (coefficient) in
                guard let self = self else { return }
                self.calculateAndBind(with: coefficient)
            })
            .disposed(by: disposeBag)
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
                (makeSymptomsGuideView(), 40),
                (buttonGroupsView, 75)
            ],
            bottomConstraint: true)

        addSubview(formulaView)

        formulaView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 14, left: 15, bottom: 30, right: 15))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Formula Calculator
extension FormulaSourceView {
    func observeElementEventsAndCalculateScore() {
        calculatorDisposable?.dispose()
        let confirmsWeightRelay = caseFormulaIndicatorView.weightRelay
        let behaviorsWeightRelay = behaviorFormulaIndicatorView.weightRelay
        let symptomsWeightRelay = symptomFormulaIndicatorView.weightRelay

        calculatorDisposable = BehaviorRelay.combineLatest(confirmsWeightRelay, behaviorsWeightRelay, symptomsWeightRelay, symptomWeightsRelay)
            .subscribe(onNext: { [weak self] (confirmWeight, behaviorsWeight, symptomsWeight, symptomWeights) in
                guard let self = self, let coefficient = FormulaSupporter.coefficientRelay.value?.v else {
                    return
                }

                if let displayingCell = FormulaSupporter.displayingCell, displayingCell.formulaSourceView != self {
                    return
                }

                var newCoefficient = coefficient
                newCoefficient.confirms = confirmWeight
                newCoefficient.behaviors = behaviorsWeight
                newCoefficient.symptoms = symptomsWeight

                let newSymptomWeights = newCoefficient.symptomWeights.map { (symptomWeight) -> SymptomWeight in
                    var newSymptomWeight = symptomWeight
                    newSymptomWeight.weight = symptomWeights.first(where: { $0.0 == newSymptomWeight.symptom.id })?.1 ?? 0
                    return newSymptomWeight
                }
                newCoefficient.symptomWeights = newSymptomWeights

                if newCoefficient != coefficient {
                    FormulaSupporter.coefficientRelay.accept((actor: self, v: newCoefficient))
                }
            })
    }

    func calculateAndBind(with coefficient: Coefficient) {
        guard let areaProfile = areaProfile else { return }

        let confirmsPart = areaProfile.details.confirm.score * coefficient.confirms
        let behaviorsPart = areaProfile.details.behaviors.score * coefficient.behaviors
        let symptomsPart = areaProfile.details.symptoms.score * coefficient.symptoms

//        let maxWeight = coefficient.symptomWeights.map { $0.weight }.sum()
//        let totalWeight = maxWeight + areaProfile.details.symptoms.customizedWeight
//
//        let symptomScore = calSymptomsScore(totalWeight: totalWeight, maxWeight: maxWeight)
//        let symptomsPart = symptomScore * coefficient.symptoms

//        caseFormulaIndicatorView.setData(score: confirmsPart)
//        behaviorFormulaIndicatorView.setData(score: behaviorsPart)
//        symptomsTotalWeightDataView.setValue(totalWeight)
//        symptomsMaxWeightDataView.setValue(maxWeight)
//        symptomFormulaIndicatorView.setData(score: symptomsPart)

        let score = confirmsPart + behaviorsPart + symptomsPart
        scoreRelay.accept(score)
        scoreLabel.setText("\(Int(score))")
    }

    fileprivate func calSymptomsScore(totalWeight: Int, maxWeight: Int) -> Float {
        guard let areaProfile = areaProfile else { return 0 }

        let symptomDetails = areaProfile.details.symptoms

        let part1 = Float(symptomDetails.totalPeople * symptomDetails.maxWeight)
        if part1 == 0 {
            return 100 - Float(symptomDetails.customizedWeight)
        }
        let part2 = Float(totalWeight) / part1

        return 100 - (100 * part2 + Float(symptomDetails.customizedWeight))
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
                    font: R.font.ibmPlexMonoMedium(size: 18),
                    themeStyle: .blackTextColor)
        return label
    }

    fileprivate func makeConfirmedCasesGuideView() -> UIView {
        let titleLabel = makeBoldLabel(text: R.string.localizable.confirmedCasesScore())

        let view =  LinearView(
            items: [
                (titleLabel, 0),
                (confirmedCasesFormulaView, 0)],
            bottomConstraint: true)

        view.addSubview(confirmScoreLabel)
        confirmScoreLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.bottom.equalTo(confirmedCasesFormulaView.snp.top).offset(23)
        }

        return view
    }

    fileprivate func makeBehaviorsGuideView() -> UIView {
        let titleLabel = makeBoldLabel(text: R.string.localizable.reportedBehaviorsScore())
        let descriptionLabel = makeLabel(R.string.localizable.reportedBehaviorsScoreDesc())

        let view = LinearView(
            items: [
                (titleLabel, 0),
                (descriptionLabel, 15),
                (behaviorsFormulaView, -10)
            ],
            bottomConstraint: true)

        view.addSubview(behaviorsScoreLabel)
        behaviorsScoreLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.bottom.equalTo(behaviorsFormulaView.snp.top).offset(40)
        }

        return view
    }

    fileprivate func makeSymptomsGuideView() -> UIView {
        let titleLabel = makeBoldLabel(text: R.string.localizable.reportedSymptomsScore())
        let descriptionLabel = makeLabel(R.string.localizable.reportedSymptomsScoreDesc())

        let view = LinearView(
            items: [
                (titleLabel, 0),
                (descriptionLabel, 15),
                (symptomWeightsStackView, 30),
                (symptomsFormulaView, 10)],
            bottomConstraint: true)

        view.addSubview(symptomsScoreLabel)
        symptomsScoreLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.bottom.equalTo(symptomsFormulaView.snp.top).offset(40)
        }

        return view
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
        formulaView.addPart(FigLabel("(", height: behaviorElementHeight))
        formulaView.addPart(behaviorsTotalPeopleDataView)
        formulaView.addPart(FigLabel("*", height: behaviorElementHeight))
        formulaView.addPart(behaviorsMaxScorePerPersonDataView)
        formulaView.addPart(FigLabel(")", height: behaviorElementHeight))
        formulaView.addPart(FigLabel("+", height: behaviorElementHeight))
        formulaView.addPart(behaviorsTotalCustomizedDataView)
        formulaView.addPart(FigLabel(")", height: behaviorElementHeight))
        return formulaView
    }

    fileprivate func makeSymptomsFormulaView() -> FormulaView {
        let formulaView = FormulaView()
        formulaView.addPart(FigLabel(R.string.localizable.symptoms_score(), height: symptomElementHeight))
        formulaView.addPart(FigLabel("=", height: symptomElementHeight))
        formulaView.addPart(FigLabel("100 -", height: symptomElementHeight))
        formulaView.addPart(FigLabel("100 *", height: symptomElementHeight))
        formulaView.addPart(FigLabel("(", height: symptomElementHeight))
        formulaView.addPart(symptomsTotalWeightDataView)
        formulaView.addPart(FigLabel("/", height: symptomElementHeight))
        formulaView.addPart(FigLabel("((", height: symptomElementHeight))
        formulaView.addPart(symptomsTotalPeopleDataView)
        formulaView.addPart(FigLabel("*", height: symptomElementHeight))
        formulaView.addPart(symptomsMaxWeightDataView)
        formulaView.addPart(FigLabel(") +", height: symptomElementHeight))
        formulaView.addPart(symptomsCustomizedWeightDataView)
        formulaView.addPart(FigLabel(")", height: symptomElementHeight))
        formulaView.addPart(FigLabel(")", height: symptomElementHeight))
        return formulaView
    }

    fileprivate func makeSymptomWeightsStackView() -> UIStackView {
        let stackView = UIStackView(
            arrangedSubviews: [],
            axis: .vertical,
            spacing: 7)
        return stackView
    }

    fileprivate func buildSymptomWeightsStackView(with symptomWeights: [SymptomWeight]) {
        localSymptomWeightsDisposable?.dispose()
        symptomWeightsStackView.removeArrangedSubviews()
        symptomWeightsStackView.removeSubviews()

        for symptomWeight in symptomWeights {
            let symptomWeightView = SymptomWeightView(for: symptomWeight.symptom)
            symptomWeightView.setInitWeightValue(symptomWeight.weight)

            symptomWeightsStackView.addArrangedSubview(symptomWeightView)
        }

        guard let symptomWeightViews = symptomWeightsStackView.arrangedSubviews as? [SymptomWeightView] else {
            return
        }

        let arrayOfSymptomWeights = symptomWeightViews.map { $0.weightRelay
            .distinctUntilChanged { $0.1 == $1.1 } }

        localSymptomWeightsDisposable = Observable.combineLatest(arrayOfSymptomWeights)
            .bind(to: symptomWeightsRelay)

        localSymptomWeightsDisposable?.disposed(by: disposeBag)
    }

    fileprivate func  makeIndicatorScoreLabel() -> Label {
        let label = Label()
        label.font = R.font.ibmPlexMonoLight(size: 14)
        return label
    }

    fileprivate func makeFigDataView(topInfo: String, height: CGFloat) -> FigDataView {
        let figDataView =  FigDataView(topInfo: topInfo, height: height)
        figDataView.button.rx.tap.bind { [weak self] in
            self?.delegate?.explainData()
        }.disposed(by: disposeBag)
        return figDataView
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

        button.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.isUserInteractionEnabled = false
            self.delegate?.resetFormula()
        }.disposed(by: disposeBag)

        return button
    }
}
