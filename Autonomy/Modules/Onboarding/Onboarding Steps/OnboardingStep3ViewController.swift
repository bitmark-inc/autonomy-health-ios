//
//  OnboardingStep3ViewController.swift
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

class OnboardingStep3ViewController: ViewController, BackNavigator, OnboardingViewLayout {

    // MARK: - Properties
    lazy var headerScreen: UIView = {
        HeaderView(header: "3")
    }()
    lazy var titleScreen = makeTitleScreen(title: R.string.phrase.onboarding3Description())
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
            self?.gotoPermissionScreen()
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
extension OnboardingStep3ViewController {
    fileprivate func gotoPermissionScreen() {
        navigator.show(segue: .permission, sender: self)
    }
}

extension OnboardingStep3ViewController {
    func makeContentTalkingView() -> UIView {
        let image = ImageView(image: R.image.nextCircleArrow())

        let helpFoodLabel = Label()
        helpFoodLabel.apply(text: R.string.phrase.helpDeliverFood(),
                    font: R.font.atlasGroteskLight(size: 24),
                    themeStyle: .lightTextColor)

        let helpFoodDescLabel = Label()
        helpFoodDescLabel.apply(text: R.string.phrase.helpDeliverFoodDescription(),
            font: R.font.atlasGroteskLight(size: 14),
            themeStyle: .silverChaliceColor, lineHeight: 1.2)
        helpFoodDescLabel.numberOfLines = 0

        let leftView = LinearView(
            (helpFoodLabel, 10),
            (helpFoodDescLabel, 8))

        let view = UIView()
        view.addSubview(leftView)
        view.addSubview(image)

        leftView.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalToSuperview().offset(-50)
        }

        image.snp.makeConstraints { (make) in
            make.top.trailing.equalToSuperview()
        }

        return view

    }
}
