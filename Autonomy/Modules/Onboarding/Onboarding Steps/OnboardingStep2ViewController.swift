//
//  OnboardingStep2ViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/26/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SwifterSwift

class OnboardingStep2ViewController: ViewController, BackNavigator, OnboardingViewLayout {

    // MARK: - Properties
    lazy var headerScreen: UIView = {
        HeaderView(header: "1      <b>2</b>      3")
    }()
    lazy var titleScreen = makeTitleScreen(title: R.string.phrase.onboarding2Description())
    lazy var talkingImageView = makeTalkingImageView()
    lazy var backButton = makeLightBackItem()
    lazy var nextButton = RightIconButton(title: R.string.localizable.next().localizedUppercase,
                     icon: R.image.nextCircleArrow()!)
    lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: nextButton, hasGradient: true)
    }()

    lazy var sampleSymptomsTagView = makeSampleSymptomTagListView()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        sampleSymptomsTagView.rearrangeViews()
    }

    // MARK: bindViewModel
    override func bindViewModel() {
        super.bindViewModel()

        nextButton.rx.tap.bind { [weak self] in
            self?.gotoOnboardingStep3Screen()
        }.disposed(by: disposeBag)
    }

    // MARK: Setup views
    override func setupViews() {
        super.setupViews()

        let paddingContentView = makePaddingContentView()

        contentView.addSubview(paddingContentView)
        contentView.addSubview(groupsButton)

        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(OurTheme.paddingInset)
        }

        groupsButton.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(contentView)
        }
    }
}

// MARK: - Navigator
extension OnboardingStep2ViewController {
    fileprivate func gotoOnboardingStep3Screen() {
        navigator.show(segue: .onboardingStep3, sender: self)
    }
}

extension OnboardingStep2ViewController {
    func makeContentTalkingView() -> UIView {
        let titleLabel = Label()
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.apply(
            text: R.string.phrase.onboardingSymptomsTitle(),
            font: R.font.atlasGroteskLight(size: Size.ds(24)),
            themeStyle: .lightTextColor, lineHeight: 1.2)

        let titleLabelCover = UIView()
        titleLabelCover.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.85)
            make.top.bottom.centerX.equalToSuperview()
        }

        return LinearView(
            items: [
                (titleLabelCover        , 0),
                (SeparateLine(height: 1), Size.dh(35)),
                (sampleSymptomsTagView  , Size.dh(25))
            ])
    }

    fileprivate func makeSampleSymptomTagListView() -> TagListView {
        let tagListView = TagListView()
        let sampleSymptomTexts = [
            R.string.phrase.sampleSymtomDryCough(),
            R.string.phrase.sampleSymptomFever(),
            R.string.phrase.sampleSymptomChills(),
            R.string.phrase.sampleSymptomFatigue(),
            R.string.phrase.sampleSymptomShortnessOfBreath(),
            R.string.phrase.sampleSymptomDifficultyBreathing(),
            R.string.phrase.sampleSymptomLossOfSenseOfTasteOrSmell()
            ].map { (id: "", value: $0) }

        tagListView.addTags(sampleSymptomTexts)
        return tagListView
    }
}
