//
//  SignInWallViewController.swift
//  Autonomy
//
//  Created by thuyentruong on 11/19/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SwifterSwift

class SignInWallViewController: ViewController {

    // MARK: - Properties
    lazy var headerScreen = HeaderView(header: R.string.phrase.launchName().localizedUppercase)
    lazy var titleScreen = makeTitleScreen()
    lazy var launchPolygonImage = ImageView(image: R.image.onboardingLaunch())
    lazy var termsAndPolicyView = makeTermsAndPolicyView()
    lazy var getStartedButton = makeGetStartedButton()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: Handlers
    override func bindViewModel() {
        super.bindViewModel()

        getStartedButton.rxTap.bind { [weak self] in
            self?.gotoOnboardingScreen()
        }.disposed(by: disposeBag)
    }

    // MARK: Setup views
    override func setupViews() {
        super.setupViews()

        // *** Setup subviews ***
        let paddingContentView = UIView()
        paddingContentView.addSubview(headerScreen)
        paddingContentView.addSubview(titleScreen)
        paddingContentView.addSubview(launchPolygonImage)
        paddingContentView.addSubview(termsAndPolicyView)
        paddingContentView.addSubview(getStartedButton)

        headerScreen.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        titleScreen.snp.makeConstraints { (make) in
            make.top.equalTo(headerScreen.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(launchPolygonImage.snp.top).offset(-10)
        }

        launchPolygonImage.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(view.height * 0.33)
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.32)
        }

        getStartedButton.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
        }

        termsAndPolicyView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(getStartedButton.snp.top).offset(-29)
        }

        contentView.addSubview(paddingContentView)
        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(OurTheme.paddingInset)
        }
    }
}

// MARK: UITextViewDelegate
extension SignInWallViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard URL.scheme != nil, let host = URL.host else {
            return false
        }

        guard let appLink = AppLink(rawValue: host),
            let appLinkURL = appLink.websiteURL
        else {
            return true
        }

        navigator.show(segue: .safariController(appLinkURL), sender: self, transition: .alert)
        return true
    }
}

// MARK: - Navigator
extension SignInWallViewController {
    fileprivate func gotoOnboardingScreen() {
        navigator.show(segue: .onboardingStep1, sender: self)
    }
}

extension SignInWallViewController {
    fileprivate func makeGetStartedButton() -> SubmitButton {
        return SubmitButton(
            title: R.string.localizable.start().localizedUppercase,
            icon: R.image.nextCircleArrow()!)
    }

    fileprivate func makeTitleScreen() -> CenterView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.launchDescription(),
                    font: R.font.atlasGroteskLight(size: Size.ds(64)),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return CenterView(contentView: label)
    }

    fileprivate func makeTermsAndPolicyView() -> ReadingTextView {
        let textView = ReadingTextView()
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.linkTextAttributes = [
          .foregroundColor: themeService.attrs.lightTextColor
        ]
        textView.attributedText = LinkAttributedString.make(
            string: R.string.phrase.launchPolicyTerm(AppLink.digitalRights.generalText),
            lineHeight: 1.3,
            attributes: [
                .font: R.font.atlasGroteskLight(size: 14)!,
                .foregroundColor: themeService.attrs.lightTextColor
            ], links: [
                (text: AppLink.digitalRights.generalText, url: AppLink.digitalRights.path)
            ], linkAttributes: [
                .font: R.font.atlasGroteskLight(size: 14)!,
                .underlineColor: themeService.attrs.lightTextColor,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ])

        return textView
    }
}
