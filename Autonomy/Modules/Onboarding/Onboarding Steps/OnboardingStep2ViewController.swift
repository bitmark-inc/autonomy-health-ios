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
    lazy var nextButton = SubmitButton(title: R.string.localizable.next().localizedUppercase,
                     icon: R.image.nextCircleArrow()!)
    lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: nextButton, hasGradient: true)
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: bindViewModel
    override func bindViewModel() {
        super.bindViewModel()

        nextButton.rxTap.bind { [weak self] in
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
            text: R.string.phrase.onboarding2Title(),
            font: R.font.atlasGroteskLight(size: Size.ds(24)),
            themeStyle: .lightTextColor, lineHeight: 1.2)

        let titleLabelCover = UIView()
        titleLabelCover.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-20)
            make.top.bottom.centerX.equalToSuperview()
        }

        let sampleItem1 = makeSampleCheckBox(
            title: R.string.phrase.onboarding2Item1(),
            description: R.string.phrase.onboarding2Item1Desc())

        let sampleItem2 = makeSampleCheckBox(
            title: R.string.phrase.onboarding2Item2(),
            description: R.string.phrase.onboarding2Item2Desc())

        return LinearView(
            items: [
                (titleLabelCover        , 0),
                (SeparateLine(height: 1), Size.dh(23)),
                (sampleItem1         , Size.dh(28)),
                (sampleItem2, 15)
            ])
    }

    fileprivate func makeSampleCheckBox(title: String, description: String) -> CheckboxView {
        let checkBox = CheckboxView(title: title, description: description)
        checkBox.checkBox.on = true
        checkBox.isUserInteractionEnabled = false
        return checkBox
    }
}
