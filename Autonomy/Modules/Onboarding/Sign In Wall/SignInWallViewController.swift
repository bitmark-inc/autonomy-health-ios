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
import SwiftRichString

class SignInWallViewController: ViewController {

    // MARK: - Properties
    lazy var headerScreen = HeaderView(header: R.string.phrase.launchName().localizedUppercase)
    lazy var titleScreen = makeTitleScreen()
    lazy var launchPolygonImage = ImageView(image: R.image.onboardingLaunch())
    lazy var digitalRightsView = makeDigitalRightsView()
    lazy var getStartedButton = makeGetStartedButton()
    lazy var signInTextView = makeSignInTextView()

    // MARK: Handlers
    override func bindViewModel() {
        super.bindViewModel()

        getStartedButton.rx.tap.bind { [weak self] in
            self?.gotoOnboardingScreen()
        }.disposed(by: disposeBag)
    }

    // MARK: Setup views
    override func setupViews() {
        super.setupViews()

        let bottomView = UIView()
        bottomView.addSubview(signInTextView)
        bottomView.addSubview(digitalRightsView)

        signInTextView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
        }

        digitalRightsView.snp.makeConstraints { (make) in
            make.top.equalTo(signInTextView.snp.bottom)
            make.centerX.bottom.equalToSuperview()
        }

        // *** Setup subviews ***
        let paddingContentView = UIView()
        paddingContentView.addSubview(headerScreen)
        paddingContentView.addSubview(titleScreen)
        paddingContentView.addSubview(launchPolygonImage)
        paddingContentView.addSubview(getStartedButton)
        paddingContentView.addSubview(bottomView)

        headerScreen.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        titleScreen.snp.makeConstraints { (make) in
            make.top.equalTo(headerScreen.snp.bottom).offset(Size.dh(35))
            make.leading.trailing.equalToSuperview()
        }

        launchPolygonImage.snp.makeConstraints { (make) in
            make.top.equalTo(titleScreen.snp.bottom).offset(Size.dh(35))
            make.centerX.equalToSuperview()
            make.bottom.equalTo(getStartedButton.snp.top).offset(-Size.dh(30))
        }

        getStartedButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
            make.height.equalTo(Size.dh(60))
        }

        bottomView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(Size.dh(102))
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

        guard let appLink = AppLink(rawValue: host) else { return false }
        switch appLink {
        case .signIn:
            gotoSignInScreen()

        default:
            guard let appLinkURL = appLink.websiteURL else { return false }
            navigator.show(segue: .safariController(appLinkURL), sender: self, transition: .alert)
        }

        return true
    }
}

// MARK: - Navigator
extension SignInWallViewController {
    fileprivate func gotoOnboardingScreen() {
        navigator.show(segue: .onboardingStep1, sender: self)
    }

    fileprivate func gotoSignInScreen() {
        let viewModel = SignInViewModel()
        navigator.show(segue: .signIn(viewModel: viewModel), sender: self)
    }

}

extension SignInWallViewController {
    fileprivate func makeGetStartedButton() -> RightIconButton {
        let button = RightIconButton(
            title: R.string.localizable.start().localizedUppercase,
            icon: R.image.nextCircleArrow()!)
        button.imageView?.contentMode = .scaleAspectFit
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.apply(font: R.font.domaineSansTextLight(size: Size.ds(36)))
        return button
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

    fileprivate func makeDigitalRightsView() -> UITextView {
        let textView = makeTextView()
        textView.attributedText = R.string.phrase.launchDigitalRights()
                                   .set(style: styleGroup)
        return textView
    }

    fileprivate func makeSignInTextView() -> UITextView {
        let textView = makeTextView()
        textView.attributedText = R.string.phrase.onboardingSignIn()
                                   .set(style: styleGroup)
        return textView
    }

    fileprivate func makeTextView() -> UITextView {
        let textColor = themeService.attrs.concordColor
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.sizeToFit()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.linkTextAttributes = [
            .foregroundColor: textColor
        ]
        return textView
    }

    var styleGroup: StyleXML {
        let textColor = themeService.attrs.concordColor

        return {
            let style = Style {
                $0.font = R.font.atlasGroteskLight(size: 14)
                $0.color = textColor
            }

            let signIn = Style {
                $0.linkURL = AppLink.signIn.appURL
                $0.underline = (NSUnderlineStyle.single, textColor)
            }

            let digitalRights = Style {
                $0.linkURL = AppLink.digitalRights.appURL
                $0.underline = (NSUnderlineStyle.single, textColor)
            }

            return StyleXML(base: style, [
                "sign-in": signIn,
                "digital-rights": digitalRights
            ])
        }()
    }
}
