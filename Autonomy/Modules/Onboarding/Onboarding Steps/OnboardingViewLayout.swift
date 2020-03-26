//
//  OnboardingViewLayout.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/26/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit

protocol OnboardingViewLayout {
    var headerScreen: UIView { get }
    var titleScreen: CenterView { get }
    var talkingImageView: UIView { get }
    var groupsButton: UIView { get }

    func makePaddingContentView() -> UIView
    func makeTitleScreen(title: String) -> CenterView
    func makeTalkingImageView() -> UIView
    func makeContentTalkingView() -> UIView
}

extension OnboardingViewLayout where Self: UIViewController {
    func makePaddingContentView() -> UIView {
        let paddingContentView = UIView()
        paddingContentView.addSubview(headerScreen)
        paddingContentView.addSubview(titleScreen)
        paddingContentView.addSubview(talkingImageView)
        paddingContentView.addSubview(groupsButton)

        paddingContentView.backgroundColor = .clear

        headerScreen.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        titleScreen.snp.makeConstraints { (make) in
            make.top.equalTo(headerScreen.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(talkingImageView.snp.top).offset(-10)
        }

        talkingImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(view.height * 0.45)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-45)
        }

        groupsButton.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
        }

        return paddingContentView
    }

    func makeTitleScreen(title: String) -> CenterView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: title,
                    font: R.font.atlasGroteskLight(size: 36),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return CenterView(contentView: label)
    }

    func makeTalkingImageView() -> UIView {
        let phoneImageView = ImageView(image: R.image.onboardingPhone())
        phoneImageView.contentMode = .scaleToFill

        let contentTalkingView = makeContentTalkingView()

        let view = UIView()
        view.addSubview(phoneImageView)
        view.addSubview(contentTalkingView)

        phoneImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        contentTalkingView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 60, left: 18, bottom: 0, right: 18))
        }

        return view
    }
}
