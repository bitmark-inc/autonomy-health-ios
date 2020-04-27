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

    fileprivate let disposeBag = DisposeBag()

    // Constants
    fileprivate let healthViewHeight: CGFloat = HealthScoreTriangle.originalSize.height * HealthScoreTriangle.scale

    // Formula View
    lazy var topSpacing: CGFloat = {
        return frame.height - formulaDragHeight
    }()

    var formulaDragHeight: CGFloat {
        let requiredTopSpacing: CGFloat = healthViewHeight / 2 + 120
        let sizeOfFormula = scrollView.contentSize.height
        let limitHeight = UIScreen.main.bounds.height - requiredTopSpacing
        return min(sizeOfFormula, limitHeight)
    }
    let formulaViewAnimateDuration: CGFloat = 0.9
    let bottomY = UIScreen.main.bounds.height + 10
    let topHealthView: CGFloat = Size.dh(70)

    enum BottomSlideViewState {
        case expanded
        case collpased
    }

    var bottomSlideViewVisible = false
    var nextState:BottomSlideViewState {
        return bottomSlideViewVisible ? .collpased : .expanded
    }

    // Animation Supports
    var animations:[UIViewPropertyAnimator] = []
    var animationProgressWhenIntrupped:CGFloat = 0

    var topFormulaViewConstraint: Constraint?
    var heightScrollViewConstraint: Constraint?
    var topHealthViewConstraint: Constraint?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        heightScrollViewConstraint?.update(offset: formulaDragHeight)
    }

    fileprivate func setupViews() {
        let paddingContentView = UIView()
        paddingContentView.addSubview(locationLabel)
        paddingContentView.addSubview(healthView)
        paddingContentView.addSubview(guideDataView)

        locationLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.7)
            make.top.centerX.equalToSuperview()
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
            make.leading.trailing.equalToSuperview()
            make.width.equalToSuperview()
            heightScrollViewConstraint = make.height.equalTo(100).constraint
            topFormulaViewConstraint = make.top.equalToSuperview().offset(bottomY).constraint
        }

        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 0, left: OurTheme.horizontalPadding, bottom: 0, right: OurTheme.horizontalPadding))
        }

        healthView.addGestureRecognizer(tapHealthViewGesture)
    }

    func setData(areaProfile: AreaProfile?, locationName: String) {
        guard let areaProfile = areaProfile else {
            guideDataView.showAnimatedSkeleton(usingColor: Constant.skeletonColor)
            return
        }

        guideDataView.hideSkeleton()
        rebuildHealthView(score: areaProfile.displayScore)
        bindInfo(for: .confirmedCases, number: areaProfile.confirm, delta: areaProfile.confirmDelta)
        bindInfo(for: .reportedSymptoms, number: areaProfile.symptoms, delta: areaProfile.symptomsDelta)
        bindInfo(for: .healthyBehaviors, number: areaProfile.behavior, delta: areaProfile.behaviorDelta)

        locationLabel.setText(locationName)
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

    fileprivate func rebuildHealthView(score: Int?) {
        let newHealthView = makeHealthScoreView(score: score)

        healthView.removeSubviews()
        healthView.addSubview(newHealthView)

        newHealthView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    fileprivate func formatNumber(_ number: Int) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: number))
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

        let moveUpAnimation = UIViewPropertyAnimator.init(duration: TimeInterval(formulaViewAnimateDuration), dampingRatio: 1.0) { [weak self] in
            guard let self = self else  { return }
            switch state {
            case .collpased:
                self.topFormulaViewConstraint?.update(offset: self.bottomY)
                self.healthView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.topHealthViewConstraint?.update(offset: self.topHealthView)
            case .expanded:
                self.topFormulaViewConstraint?.update(offset: self.topSpacing)
                self.healthView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.topHealthViewConstraint?.update(offset: -50)
            }

            self.layoutIfNeeded()
        }
        moveUpAnimation.addCompletion { [weak self] _ in
            guard let self = self else { return }
            self.bottomSlideViewVisible =  state ==  .collpased ? false : true
            self.animations.removeAll()
        }

        moveUpAnimation.startAnimation()
        animations.append(moveUpAnimation)
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
            let fraction = bottomSlideViewVisible ? fractionCompleted : -fractionCompleted
            updateIntractiveAnimation(animationProgress: fraction)

        case .ended:
            scrollView.isUserInteractionEnabled = true
            continueAnimation(finalVelocity: gestureRecognizer.velocity(in: scrollView))

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
        if bottomSlideViewVisible == (finalVelocity.y < 0) {
            for animation in animations {
                animation.stopAnimation(true)
            }
            animations.removeAll()
            self.bottomSlideViewVisible =  !self.bottomSlideViewVisible
            self.createAnimation(state: nextState)

        } else {
            for animation in animations {
                animation.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            }
        }
    }
}

// MARK: - Setup views
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

    fileprivate func makeFormularSourceView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white

            let formulaView = FormulaSourceView()
        view.addSubview(formulaView)

        formulaView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        return view
    }

    fileprivate func makeTapHealthViewGesture() -> UITapGestureRecognizer {
        let tapGestureRecogniter = UITapGestureRecognizer()
        tapGestureRecogniter.rx.event.bind { [weak self] (_) in
            guard let self = self else { return }
            self.createAnimation(state: self.nextState)
        }.disposed(by: disposeBag)
        return tapGestureRecogniter
    }
}
