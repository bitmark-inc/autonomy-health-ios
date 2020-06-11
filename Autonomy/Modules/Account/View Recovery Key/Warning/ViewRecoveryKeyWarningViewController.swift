//
//  ViewRecoveryKeyWarningViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 12/13/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewRecoveryKeyWarningViewController: ViewController, BackNavigator {

    // MARK: - Properties
    fileprivate lazy var screenTitle = makeScreenTitle()
    fileprivate lazy var contentLabel = makeContentLabel()
    fileprivate lazy var backButton = makeLightBackItem()
    fileprivate lazy var nextButton = RightIconButton(title:R.string.localizable.next().localizedUppercase,
                                                      icon: R.image.nextCircleArrow())
    fileprivate lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: nextButton, hasGradient: false)
    }()

    override func bindViewModel() {
        super.bindViewModel()

        nextButton.rx.tap.bind {
            _ = BiometricAuth.authorizeAccess()
                .observeOn(MainScheduler.instance)
                .subscribe(onCompleted: { [weak self] in
                    self?.gotoViewRecoveryKeyScreen()
                })
        }.disposed(by: disposeBag)
    }

    override func setupViews() {
        super.setupViews()

        // *** Setup subviews ***
        let paddingContentView = LinearView(
            items: [
                (screenTitle, 0),
                (contentLabel, Size.dh(66))
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

extension ViewRecoveryKeyWarningViewController {
    fileprivate func gotoViewRecoveryKeyScreen() {
        let viewModel = ViewRecoveryKeyViewModel()
        navigator.show(segue: .viewRecoveryKey(viewModel: viewModel), sender: self)
    }
}

extension ViewRecoveryKeyWarningViewController {
    fileprivate func makeScreenTitle() -> Label {
        let label = Label()
        label.apply(text: R.string.phrase.viewRecoveryKeyTitle(),
                    font: R.font.atlasGroteskLight(size: 24),
                    themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeContentLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.viewRecoveryKeyDescription(),
                    font: R.font.atlasGroteskLight(size: 18),
                    themeStyle: .lightTextColor, lineHeight: 1.25)
        return label
    }
}
