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
    var thisActor: String {
        return key ?? ""
    }
    lazy var scoreLabel = makeScoreLabel()

    fileprivate lazy var caseFormulaIndicatorView = FormulaIndicatorView(for: .confirmedCases)
    fileprivate lazy var symptomFormulaIndicatorView = FormulaIndicatorView(for: .reportedSymptoms)
    fileprivate lazy var behaviorFormulaIndicatorView = FormulaIndicatorView(for: .healthyBehaviors)
    fileprivate lazy var resetButton = makeResetButton()
    fileprivate lazy var sourceInfoLabel = makeSourceInfoLabel()
    fileprivate lazy var jupyterNotebookButton = makeJupyterNotebookButton()

    fileprivate var calculatorDisposable: Disposable?

    weak var delegate: ScoreSourceDelegate?
    var key: String?
    fileprivate let disposeBag = DisposeBag()

    // - Indicator
    let scoreRelay = BehaviorRelay<Float>(value: 0)
    var areaProfile: AreaProfile?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()

        bindFormulaWeightEvents()

        FormulaSupporter.shared.defaultStateRelay
            .map { $0 == .custom }
            .bind(to: resetButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    deinit {
        calculatorDisposable?.dispose()
    }

    // MARK: - Handles Data
    func setData(areaProfile: AreaProfile) {
        self.areaProfile = areaProfile

        // Global Score
        scoreLabel.setText("\(areaProfile.score.formatScoreInt)")
        scoreLabel.textColor = HealthRisk(from: Int(areaProfile.score))?.color

        ///
        let confirmDetails = areaProfile.details.confirm
        let symptomsDetails = areaProfile.details.symptoms
        let behaviorsDetails = areaProfile.details.behaviors

        // Weight Score
        caseFormulaIndicatorView.setData(score: confirmDetails.score)
        symptomFormulaIndicatorView.setData(score: symptomsDetails.score)
        behaviorFormulaIndicatorView.setData(score: behaviorsDetails.score)
    }

    func setRemoteData(coefficient: Coefficient, onlySlider: Bool = false) {
        caseFormulaIndicatorView.setInitWeightValue(coefficient.confirms, skipValueRelay: onlySlider)
        behaviorFormulaIndicatorView.setInitWeightValue(coefficient.behaviors, skipValueRelay: onlySlider)
        symptomFormulaIndicatorView.setInitWeightValue(coefficient.symptoms, skipValueRelay: onlySlider)
    }

    fileprivate func bindFormulaWeightEvents() {
        let coefficientRelayShare = FormulaSupporter.shared.coefficientRelay
            .observeOn(MainScheduler.asyncInstance)
            .filterNil()
            .filter { [weak self] in
                guard let self = self else { return false }
                return $0.actor == nil || $0.actor != self.thisActor
            }
            .map { $0.v }
            .share()

        // only observe after setting remote data the first time
        coefficientRelayShare
            .take(1)
            .subscribe(onNext: { [weak self] (coefficient) in
                guard let self = self else { return }
                self.isUserInteractionEnabled = true
                self.setRemoteData(coefficient: coefficient)
                self.observeElementEventsAndCalculateScore()
            })
            .disposed(by: disposeBag)

        coefficientRelayShare
            .skip(1)
            .subscribe(onNext: { [weak self] (coefficient) in
                guard let self = self else { return }
                self.isUserInteractionEnabled = true
                self.setRemoteData(coefficient: coefficient, onlySlider: true)
            })
            .disposed(by: disposeBag)

        // Calculate
        FormulaSupporter.shared.coefficientRelay
            .observeOn(MainScheduler.asyncInstance)
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
                (symptomFormulaIndicatorView, 0),
                (makeLabel("+"), 0),
                (behaviorFormulaIndicatorView, 0),
                (CenterView(contentView: resetButton), 30),
                (sourceInfoLabel, 30),
                (CenterView(contentView: jupyterNotebookButton), 30)
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

        calculatorDisposable = BehaviorRelay.combineLatest(confirmsWeightRelay, behaviorsWeightRelay, symptomsWeightRelay)
            .subscribe(onNext: { [weak self] (confirmWeight, behaviorsWeight, symptomsWeight) in
                guard let self = self, let coefficient = FormulaSupporter.shared.coefficientRelay.value?.v else {
                    return
                }

                if let displayingCell = FormulaSupporter.shared.displayingCell, displayingCell.formulaSourceView != self {
                    return
                }

                var newCoefficient = coefficient
                newCoefficient.confirms = confirmWeight
                newCoefficient.behaviors = behaviorsWeight
                newCoefficient.symptoms = symptomsWeight

                if newCoefficient != coefficient {
                    FormulaSupporter.shared.coefficientRelay.accept((actor: self.thisActor, v: newCoefficient))
                }
            })
    }

    func calculateAndBind(with coefficient: Coefficient) {
        guard let areaProfile = areaProfile else { return }

        let confirmsPart = areaProfile.details.confirm.score * coefficient.confirms
        let behaviorsPart = areaProfile.details.behaviors.score * coefficient.behaviors
        let symptomsPart = areaProfile.details.symptoms.score * coefficient.symptoms

        let score = confirmsPart + behaviorsPart + symptomsPart
        scoreRelay.accept(score)
        scoreLabel.setText("\(Int(score))")
    }
}

extension FormulaSourceView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

        delegate?.openSafari(with: URL)
        return false
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

    fileprivate func makeLabel(_ text: String) -> UILabel {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: text,
                    font: R.font.ibmPlexMonoLight(size: 18),
                    themeStyle: .blackTextColor)

        return label
    }

    fileprivate func makeResetButton() -> UIButton {
        let button = RightIconButton(
            title: R.string.localizable.reset().localizedUppercase,
            icon: R.image.resetIcon()!,
            spacing: 7,
            edgeSpacing: 10)
        button.apply(font: R.font.atlasGroteskLight(size: 14))
        button.snp.makeConstraints { (make) in
            make.height.equalTo(30)
        }
        button.cornerRadius = 15

        themeService.rx
            .bind( { $0.concordColor }, to: button.rx.backgroundColor)
            .disposed(by: disposeBag)

        button.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.isUserInteractionEnabled = false
            self.delegate?.resetFormula()
        }.disposed(by: disposeBag)

        return button
    }

    fileprivate func makeSourceInfoLabel() -> UITextView {
        let styleGroup: StyleXML = {
            let style = Style {
                $0.font = R.font.ibmPlexMonoLight(size: 18)
                $0.color = themeService.attrs.blackTextColor
            }

            let highlight = Style {
                $0.font = R.font.ibmPlexMonoBold(size: 18)
            }

            let coronaDataProject = Style {
                $0.linkURL = AppLink.coronaDataCraper.websiteURL
                $0.underline = (NSUnderlineStyle.single, UIColor.black)
            }

            let jupyterNotebook = Style {
                $0.linkURL = AppLink.formulaJupyter.websiteURL
                $0.underline = (NSUnderlineStyle.single, UIColor.black)
            }

            return StyleXML(base: style, [
                "b": highlight,
                "corona-data-project": coronaDataProject,
                "jupyter-notebook": jupyterNotebook
            ])
        }()

        let textView = UITextView()
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.sizeToFit()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.attributedText = R.string.phrase.sourceInfo().set(style: styleGroup)
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.black
        ]
        return textView
    }

    fileprivate func makeJupyterNotebookButton() -> UIButton {
        let button = RightIconButton(
            title: R.string.localizable.jupyterNotebook().localizedUppercase,
            icon: R.image.crossCircleArrow()!,
            spacing: 7,
            edgeSpacing: 10)
        button.apply(font: R.font.atlasGroteskLight(size: 14))
        button.snp.makeConstraints { $0.height.equalTo(30) }
        button.cornerRadius = 15

        themeService.rx
            .bind( { $0.blueRibbonColor }, to: button.rx.backgroundColor)
            .disposed(by: disposeBag)

        button.rx.tap.bind { [weak self] in
            self?.delegate?.moveToJupyterNotebook()
        }.disposed(by: disposeBag)

        return button
    }
}
