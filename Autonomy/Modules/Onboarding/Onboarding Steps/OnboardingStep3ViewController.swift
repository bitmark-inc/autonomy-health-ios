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
        HeaderView(header: "1      2      <b>3</b>")
    }()
    lazy var titleScreen = makeTitleScreen(title: R.string.phrase.onboarding3Description())
    lazy var talkingImageView = makeTalkingImageView()
    lazy var backButton = makeLightBackItem()
    lazy var nextButton = RightIconButton(title: R.string.localizable.next().localizedUppercase,
                     icon: R.image.nextCircleArrow()!)
    lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: nextButton, hasGradient: true)
    }()

    // MARK: bindViewModel
    override func bindViewModel() {
        super.bindViewModel()

        nextButton.rx.tap.bind { [weak self] in
            self?.gotoPermissionScreen()
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
extension OnboardingStep3ViewController {
    fileprivate func gotoPermissionScreen() {
        navigator.show(segue: .permission, sender: self)
    }
}

extension OnboardingStep3ViewController {
    func makeContentTalkingView() -> UIView {
        let titleLabel = Label()
        titleLabel.numberOfLines = 0
        titleLabel.apply(
            text: R.string.localizable.healthyBehaviors().localizedUppercase,
            font: R.font.domaineSansTextLight(size: 18),
            themeStyle: .lightTextColor, lineHeight: 1.2)

        return LinearView(
            items: [
                (makeSampleNotificationView(), 0),
                (titleLabel, 16),
                (makeSampleColumnsView(), Size.dh(28))
            ])
    }

    fileprivate func makeSampleColumnsView() -> UIView {
        let sampleItem1 = makeSampleColumnDataView(
            title: R.string.localizable.yourTotalForToday().localizedUppercase,
            number: 7)

        let sampleItem2 = makeSampleColumnDataView(
            title: R.string.localizable.communityAverageForToday().localizedUppercase,
            number: 5)

        let dataColumnsView = UIView()
        dataColumnsView.addSubview(sampleItem1)
        dataColumnsView.addSubview(sampleItem2)

        sampleItem1.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5).offset(-7.5)
        }

        sampleItem2.snp.makeConstraints { (make) in
            make.leading.equalTo(sampleItem1.snp.trailing).offset(15)
            make.top.trailing.bottom.equalToSuperview()
        }
        return dataColumnsView
    }

    fileprivate func makeSampleColumnDataView(title: String, number: Float) -> ColumnDataView {
        let columnDataView = ColumnDataView(title: title, .good, isSample: true)
        columnDataView.setData(number: number, delta: 0)
        return columnDataView
    }

    fileprivate func makeSampleNotificationView() -> UIView {
        let autonomyLabel = Label()
        autonomyLabel.apply(text: Constant.appName.uppercased(),
                            font: UIFont.systemFont(ofSize: 11) , themeStyle: .lightTextColor)

        let appGroupView = RowView(items: [(ImageView(image: R.image.notificationAppIcon()), 0), (autonomyLabel, 7)],
                                   trailingConstraint: true)

        let notifiTitleLabel = Label()
        notifiTitleLabel.numberOfLines = 0
        notifiTitleLabel.apply(text: R.string.phrase.sampleNotificationTitle(),
                               font: UIFont.systemFont(ofSize: 13, weight: .bold),
                               themeStyle: .lightTextColor)

        let notifiMesageLabel = Label()
        notifiMesageLabel.numberOfLines = 0
        notifiMesageLabel.apply(text: R.string.phrase.sampleNotificationMessage(),
                                font: UIFont.systemFont(ofSize: 13),
                                themeStyle: .lightTextColor, lineHeight: 1.125)

        let nowLabel = Label()
        nowLabel.apply(text: R.string.localizable.now(),
                       font: UIFont.systemFont(ofSize: 11),
                       themeStyle: .lightTextColor)

        let notifiContentView = LinearView(items: [(notifiTitleLabel, 0), (notifiMesageLabel, 5)],
                                           bottomConstraint: true)

        let view = UIView()
        view.addSubview(appGroupView)
        view.addSubview(notifiContentView)
        view.addSubview(nowLabel)
        view.cornerRadius = 10

        appGroupView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(10)
        }

        notifiContentView.snp.makeConstraints { (make) in
            make.top.equalTo(appGroupView.snp.bottom).offset(9)
            make.leading.trailing.bottom.equalToSuperview()
                .inset(UIEdgeInsets(top: 0, left: 10, bottom: 12, right: 10))
        }

        nowLabel.snp.makeConstraints { (make) in
            make.top.equalTo(appGroupView)
            make.trailing.equalToSuperview().offset(-12)
        }

        themeService.rx
            .bind({ $0.mineShaftBackground }, to: view.rx.backgroundColor)
            .disposed(by: disposeBag)

        return view
    }
}
