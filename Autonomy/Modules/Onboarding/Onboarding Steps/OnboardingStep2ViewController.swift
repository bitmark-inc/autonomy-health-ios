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
        HeaderView(header: "2")
    }()
    lazy var titleScreen = makeTitleScreen(title: R.string.phrase.onboarding2Description())
    lazy var talkingImageView = makeTalkingImageView()
    lazy var backButton = makeLightBackItem()
    lazy var nextButton = SubmitButton(buttonItem: .next)
    lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: nextButton)
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: bindViewModel
    override func bindViewModel() {
        super.bindViewModel()

        nextButton.item.rx.tap.bind { [weak self] in
            self?.gotoOnboardingStep3Screen()
        }.disposed(by: disposeBag)
    }

    // MARK: Setup views
    override func setupViews() {
        super.setupViews()

        let paddingContentView = makePaddingContentView()

        contentView.addSubview(paddingContentView)
        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(OurTheme.paddingInset)
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
        let image = ImageView(image: R.image.circle51())

        let todayLabel = Label()
        todayLabel.apply(text: R.string.localizable.today().localizedUppercase,
                    font: R.font.domaineSansTextLight(size: 14),
                    themeStyle: .silverChaliceColor)

        let workFromHomeLabel = Label()
        workFromHomeLabel.apply(text: R.string.phrase.workFromHome(),
            font: R.font.atlasGroteskLight(size: 24),
            themeStyle: .lightTextColor)

        let rightView = LinearView(
            (todayLabel, 0),
            (workFromHomeLabel, 4))

        let part1View = UIView()
        part1View.addSubview(image)
        part1View.addSubview(rightView)

        image.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
        }

        rightView.snp.makeConstraints { (make) in
            make.leading.equalTo(image.snp.trailing).offset(15)
            make.top.trailing.bottom.equalToSuperview()
        }

        let textPart2Label = Label()
        textPart2Label.apply(
            text: R.string.phrase.workFromHomeDescription(),
            font: R.font.atlasGroteskLight(size: 13),
            themeStyle: .lightTextColor, lineHeight: 1.2)
        textPart2Label.numberOfLines = 0

        return LinearView(
            (part1View              , 0),
            (SeparateLine(height: 1), 30),
            (textPart2Label         , 15)
        )

    }
}
