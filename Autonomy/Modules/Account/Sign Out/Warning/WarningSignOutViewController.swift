//
//  WarningSignOutViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/17/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftRichString

class WarningSignOutViewController: ViewController, BackNavigator {

    // MARK: - Properties
    fileprivate lazy var screenTitle = makeScreenTitle()
    fileprivate lazy var messageTextView = makeMessageTextView()
    fileprivate lazy var backButton = makeLightBackItem()
    fileprivate lazy var nextButton = RightIconButton(title:R.string.localizable.next().localizedUppercase,
                                                      icon: R.image.nextCircleArrow())
    fileprivate lazy var groupsButton: UIView = {
        let groupView = ButtonGroupView(button1: backButton, button2: nextButton, hasGradient: false)
        groupView.apply(backgroundStyle: .codGrayBackground)
        return groupView
    }()

    override func bindViewModel() {
        super.bindViewModel()

        nextButton.rx.tap.bind { [weak self] in
            self?.gotoSignOutScreen()
        }.disposed(by: disposeBag)
    }

    override func setupViews() {
        super.setupViews()

        // *** Setup subviews ***
        let paddingContentView = LinearView(
            items: [
                (screenTitle, 0),
                (messageTextView, Size.dh(66))
        ])

        contentView.addSubview(paddingContentView)
        contentView.addSubview(groupsButton)

        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(OurTheme.profilePaddingInset)
        }

        groupsButton.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: UITextViewDelegate
extension WarningSignOutViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard URL.absoluteString == AppLink.viewRecoveryKey.path else { return false }
        BiometricAuth.authorizeAccess()
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in
                self?.gotoViewRecoveryKeyScreen()
            })
            .disposed(by: disposeBag)
        return true
    }
}

// MARK: - Navigator
extension WarningSignOutViewController {
    fileprivate func gotoViewRecoveryKeyScreen() {
        let viewModel = ViewRecoveryKeyViewModel()
        navigator.show(segue: .viewRecoveryKey(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoSignOutScreen() {
        let viewModel = SignOutViewModel()
        navigator.show(segue: .signOut(viewModel: viewModel), sender: self)
    }
}

// MARK: - Setup views
extension WarningSignOutViewController {
    fileprivate func makeScreenTitle() -> Label {
        let label = Label()
        label.apply(text: R.string.localizable.signOut(),
                    font: R.font.atlasGroteskLight(size: 24),
                    themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeMessageTextView() -> UITextView {
        let textColor = themeService.attrs.lightTextColor

        let styleGroup: StyleXML = {
            let style = Style {
                $0.font = R.font.atlasGroteskLight(size: 18)
                $0.color = textColor
            }

            let viewRecoveryKey = Style {
                $0.linkURL = URL(string: AppLink.viewRecoveryKey.path)
                $0.underline = (NSUnderlineStyle.single, textColor)
            }

            return StyleXML(base: style, [
                "view-recovery-key": viewRecoveryKey
            ])
        }()

        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.sizeToFit()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.attributedText = R.string.phrase.signOutMessage().set(style: styleGroup)
        textView.linkTextAttributes = [
            .foregroundColor: textColor
        ]
        return textView
    }
}
