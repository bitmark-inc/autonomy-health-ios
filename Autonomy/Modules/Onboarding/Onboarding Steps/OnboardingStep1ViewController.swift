//
//  OnboardingStep1ViewController.swift
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

class OnboardingStep1ViewController: ViewController, BackNavigator, OnboardingViewLayout {

    // MARK: - Properties
    lazy var headerScreen: UIView = {
        HeaderView(header: "<b>1</b>      2      3")
    }()
    lazy var titleScreen = makeTitleScreen(title: R.string.phrase.onboarding1Description())
    lazy var talkingImageView = makeTalkingImageView()
    lazy var backButton = makeLightBackItem()
    lazy var nextButton = RightIconButton(title: R.string.localizable.next().localizedUppercase,
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

        nextButton.rx.tap.bind { [weak self] in
            self?.gotoOnboardingStep2Screen()
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
extension OnboardingStep1ViewController {
    fileprivate func gotoOnboardingStep2Screen() {
        navigator.show(segue: .onboardingStep2, sender: self)
    }
}

extension OnboardingStep1ViewController {
    func makeContentTalkingView() -> UIView {
        return ImageView(image: R.image.onboardingHealthScore())
    }
}
