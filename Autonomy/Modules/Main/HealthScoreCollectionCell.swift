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
import PanModal
import SnapKit

enum BottomSlideViewState {
    case expanded
    case collapsed
}

class HealthScoreCollectionCell: UICollectionViewCell {

    // MARK: - Properties
    lazy var healthView = makeHealthView()
    lazy var guideDataView = makeGuideDataView()
    lazy var locationLabel = makeLocationLabel()
    lazy var scrollView = makeScrollView()
    lazy var formulaSourceView = makeFormularSourceView()
    lazy var tapHealthViewGesture = makeTapHealthViewGesture()

    // Data Guide View
    lazy var confirmedCasesView = ScoreInfoView(scoreInfoType: .confirmedCases)
    lazy var reportedSymptomsView = ScoreInfoView(scoreInfoType: .reportedSymptoms)
    lazy var healthyBehaviorsView = ScoreInfoView(scoreInfoType: .healthyBehaviors)
    lazy var populationDensityView = ScoreInfoView(scoreInfoType: .populationDensity)

    let redColor = UIColor(hexString: "#CC3232")
    let greenColor = UIColor(hexString: "#2DC937")
    var key: String? {
        didSet {
            formulaSourceView.key = key
        }
    }

    weak var scoreSourceDelegate: ScoreSourceDelegate? {
        didSet {
            bindScoreSourceEvents()
            formulaSourceView.delegate = scoreSourceDelegate
        }
    }
    fileprivate var disposeBag = DisposeBag()

    // Constants
    fileprivate let healthViewHeight: CGFloat = HealthScoreTriangle.originalSize.height * HealthScoreTriangle.scale

    // Formula View
    lazy var topSpacing: CGFloat = 270

    var formulaDragHeight: CGFloat {
        return formulaSourceView.frame.height
    }
    let formulaViewAnimateDuration: CGFloat = 0.9
    let bottomY = UIScreen.main.bounds.height + 10
    let topHealthView: CGFloat = Size.dh(70)

    var currentState: BottomSlideViewState = .collapsed
    var nextState: BottomSlideViewState {
        return currentState == .expanded ? .collapsed : .expanded
    }

    // Animation Supports
    var animations:[UIViewPropertyAnimator] = []
    var animationProgressWhenIntrupped:CGFloat = 0

    var topFormulaViewConstraint: Constraint?
    var topHealthViewConstraint: Constraint?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        bindEvents()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        animations.removeAll()
        animationProgressWhenIntrupped = 0
        healthView.resetLayout()

        disposeBag = DisposeBag()
        bindEvents()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Handlers
    fileprivate func bindScoreSourceEvents() {
        scoreSourceDelegate?.formStateRelay
            .filterNil()
            .subscribe(onNext: { [weak self] (cell, state) in
                guard let self = self , cell != self else { return }
                self.slideBottomView(with: state)
            })
            .disposed(by: disposeBag)
    }

    fileprivate func bindEvents() {
        formulaSourceView.scoreRelay
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (score) in
                guard let self = self else { return }
                setScore(score, in: self.formulaSourceView.scoreLabel)
                self.healthView.updateLayout(score: Int(score), animate: true)
            })
            .disposed(by: disposeBag)
    }

    func setData(locationName: String) {
        guard locationName.isNotEmpty else { return }
        locationLabel.setText(locationName)
    }

    func setData(areaProfile: AreaProfile?) {
        guard let areaProfile = areaProfile else {
            guideDataView.showAnimatedSkeleton(usingColor: Constant.skeletonColor)
            return
        }

        guideDataView.hideSkeleton()
        healthView.updateLayout(score: Int(areaProfile.score), animate: false)
        bindInfo(for: .confirmedCases, number: areaProfile.confirm, delta: areaProfile.confirmDelta)
        bindInfo(for: .reportedSymptoms, number: areaProfile.symptoms, delta: areaProfile.symptomsDelta)
        bindInfo(for: .healthyBehaviors, number: areaProfile.behavior, delta: areaProfile.behaviorDelta)

        formulaSourceView.setData(areaProfile: areaProfile)
    }

    fileprivate func bindInfo(for scoreInfoType: ScoreInfoType, number: Int, delta: Float) {
        let formattedNumber = number.formatNumber
        let formattedDelta = "\(abs(delta).formatPercent)%"

        switch scoreInfoType {
        case .confirmedCases:
            confirmedCasesView.currentNumberLabel.setText(formattedNumber)
            confirmedCasesView.changeNumberLabel.setText(formattedDelta)
            switch true {
            case (delta > 0):
                confirmedCasesView.changeStatusArrow.image = R.image.redUpArrow()
                confirmedCasesView.changeNumberLabel.textColor = redColor
            case (delta < 0):
                confirmedCasesView.changeStatusArrow.image = R.image.greenDownArrow()
                confirmedCasesView.changeNumberLabel.textColor = greenColor
            default:
                confirmedCasesView.changeStatusArrow.image = nil
                confirmedCasesView.changeNumberLabel.textColor = .white
            }

        case .reportedSymptoms:
            reportedSymptomsView.currentNumberLabel.setText(formattedNumber)
            reportedSymptomsView.changeNumberLabel.setText(formattedDelta)
            switch true {
            case (delta > 0):
                reportedSymptomsView.changeStatusArrow.image = R.image.redUpArrow()
                reportedSymptomsView.changeNumberLabel.textColor = redColor
            case (delta < 0):
                reportedSymptomsView.changeStatusArrow.image = R.image.greenDownArrow()
                reportedSymptomsView.changeNumberLabel.textColor = greenColor
            default:
                reportedSymptomsView.changeStatusArrow.image = nil
                reportedSymptomsView.changeNumberLabel.textColor = .white
            }

        case .healthyBehaviors:
            healthyBehaviorsView.currentNumberLabel.setText(formattedNumber)
            healthyBehaviorsView.changeNumberLabel.setText(formattedDelta)
            switch true {
            case (delta > 0):
                healthyBehaviorsView.changeStatusArrow.image = R.image.greenUpArrow()
                healthyBehaviorsView.changeNumberLabel.textColor = greenColor
            case (delta < 0):
                healthyBehaviorsView.changeStatusArrow.image = R.image.redDownArrow()
                healthyBehaviorsView.changeNumberLabel.textColor = redColor
            default:
                healthyBehaviorsView.changeStatusArrow.image = nil
                healthyBehaviorsView.changeNumberLabel.textColor = .white
            }

        case .populationDensity:
            break
        }
    }

    // MARK: - Setup Views
    fileprivate func setupViews() {
        let paddingContentView = UIView()
        paddingContentView.addSubview(locationLabel)
        paddingContentView.addSubview(healthView)
        paddingContentView.addSubview(guideDataView)

        locationLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.7)
            make.top.centerX.equalToSuperview()
            make.height.equalTo(16)
        }

        healthView.snp.makeConstraints { (make) in
            topHealthViewConstraint = make.top.equalTo(locationLabel.snp.bottom).offset(topHealthView).constraint
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(healthViewHeight)
        }

        guideDataView.snp.makeConstraints { (make) in
            make.top.equalTo(healthView.snp.bottom).offset(45)
            make.leading.trailing.equalToSuperview()
        }

        contentView.addSubview(paddingContentView)
        contentView.addSubview(scrollView)

        scrollView.snp.makeConstraints { (make) in
            make.width.bottom.leading.trailing.equalToSuperview()
            topFormulaViewConstraint = make.top.equalToSuperview().offset(bottomY).constraint
        }

        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 0, left: OurTheme.horizontalPadding, bottom: 0, right: OurTheme.horizontalPadding))
        }

        healthView.addGestureRecognizer(tapHealthViewGesture)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension HealthScoreCollectionCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - Animation Slide Formula View
    func createAnimation(state: BottomSlideViewState) {
        guard animations.isEmpty else {
            return
        }

        // setup temporary first state for other cells can show/hide bottom without waiting for finishing animation
        scoreSourceDelegate?.formStateRelay.accept((cell: self, state: state))

        let moveUpAnimation = UIViewPropertyAnimator.init(duration: TimeInterval(formulaViewAnimateDuration), dampingRatio: 1.0) { [weak self] in
            guard let self = self else  { return }
            self.slideBottomView(with: state)
            self.layoutIfNeeded()
        }
        moveUpAnimation.addCompletion { [weak self] _ in
            guard let self = self else { return }
            self.updateBottomSlideView(state: state)
            self.animations.removeAll()
        }

        moveUpAnimation.startAnimation()
        animations.append(moveUpAnimation)
    }

    func slideBottomView(with state: BottomSlideViewState) {
        switch state {
        case .collapsed:
            topFormulaViewConstraint?.update(offset: bottomY)
            healthView.transform = CGAffineTransform(scaleX: 1, y: 1)
            healthView.appNameLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            healthView.appNameLabel.alpha = 1
            topHealthViewConstraint?.update(offset: topHealthView)

        case .expanded:
            topFormulaViewConstraint?.update(offset: topSpacing)
            healthView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            healthView.appNameLabel.transform = CGAffineTransform(translationX: 300, y: 250)
            healthView.appNameLabel.alpha = 0
            topHealthViewConstraint?.update(offset: -50)
        }
    }

    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        guard gestureRecognizer.state == .ended || scrollView.contentOffset.y <= 0 else {
            return
        }

        switch gestureRecognizer.state {
        case .began:
            scrollView.isUserInteractionEnabled = false
            startIntractiveAnimation(state: nextState)

        case .changed:
            let translation = gestureRecognizer.translation(in: scrollView)
            let fractionCompleted = translation.y / formulaDragHeight
            let fraction = currentState == .expanded ? fractionCompleted : -fractionCompleted
            updateIntractiveAnimation(animationProgress: fraction)

        case .ended:
            scrollView.isUserInteractionEnabled = true
            let translation = gestureRecognizer.translation(in: scrollView)
            var finalVelocity = gestureRecognizer.velocity(in: scrollView)
            if translation.y <= 50 { // keep bottomSlideView is expanded when scrolling horizontal (slider)
                finalVelocity.y = -20.0
            }
            continueAnimation(finalVelocity: finalVelocity)

        default:
            break
        }
    }

    func startIntractiveAnimation(state:BottomSlideViewState) {
        if animations.isEmpty {
            createAnimation(state: state)
        }
        // Here we are pause the animation and get fraction Complete value and store it.
        // so when use change the animation we can update animation.fractionComplete in next method
        for animation in animations {
            animation.pauseAnimation()
            animationProgressWhenIntrupped = animation.fractionComplete
        }
    }

    func updateIntractiveAnimation(animationProgress:CGFloat)  {
        for animation in animations {
            animation.fractionComplete = animationProgress + animationProgressWhenIntrupped
        }
    }

    func continueAnimation (finalVelocity:CGPoint) {
        if (currentState == .expanded) == (finalVelocity.y < 0) {
            for animation in animations {
                animation.stopAnimation(true)
            }
            animations.removeAll()
            updateBottomSlideView(state: nextState)
            createAnimation(state: nextState)

        } else {
            for animation in animations {
                animation.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            }
        }
    }

    func updateBottomSlideView(state: BottomSlideViewState) {
        currentState = state
        scoreSourceDelegate?.formStateRelay.accept((cell: self, state: state))
    }

    @objc func tapHealthView(_ sender: UITapGestureRecognizer) {
        createAnimation(state: nextState)
    }
}

// MARK: - Setup views
extension HealthScoreCollectionCell {
    fileprivate func makeHealthView() -> HealthScoreTriangle {
        return HealthScoreTriangle(score: nil)
    }

    fileprivate func makeLocationLabel() -> Label {
        let label = Label()
        label.textAlignment = .center
        label.apply(font: R.font.atlasGroteskLight(size: 16),
                    themeStyle: .silverColor)
        return label
    }

    fileprivate func makeGuideDataView() -> UIView {
        let row1 = makeScoreInfosRow(view1: confirmedCasesView, view2: reportedSymptomsView)
        let row2 = makeScoreInfosRow(view1: healthyBehaviorsView)

        let view = UIView()
        view.isSkeletonable = true
        view.addSubview(row1)
        view.addSubview(row2)

        row1.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        row2.snp.makeConstraints { (make) in
            make.top.equalTo(row1.snp.bottom).offset(25)
            make.leading.trailing.bottom.equalToSuperview()
        }

        return view
    }

    fileprivate func makeScoreInfosRow(view1: UIView, view2: UIView? = nil) -> UIView {
        let view = UIView()
        view.addSubview(view1)
        view1.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5).offset(Size.dw(10) / 2)
        }

        if let view2 = view2 {
            view.addSubview(view2)
            view2.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalTo(view1.snp.trailing).offset(Size.dw(10))
                make.width.equalTo(view1)
            }
        }
        return view
    }

    fileprivate func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.addSubview(formulaSourceView)
        formulaSourceView.snp.makeConstraints { (make) in
            make.edges.centerX.equalToSuperview()
        }
        scrollView.backgroundColor = .white
        scrollView.bounces = false

        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        scrollView.addGestureRecognizer(gesture)
        gesture.delegate = self
        return scrollView
    }

    fileprivate func makeFormularSourceView() -> FormulaSourceView {
        return FormulaSourceView()
    }

    fileprivate func makeTapHealthViewGesture() -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(tapHealthView(_:)))
    }
}
