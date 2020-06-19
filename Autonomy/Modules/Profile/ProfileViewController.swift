//
//  ProfileViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/28/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import Intercom
import SwiftRichString

class ProfileViewController: ViewController, BackNavigator {

    // MARK: - Properties
    fileprivate lazy var scrollView = makeScrollView()
    fileprivate lazy var contentScrollView = UIView()

    fileprivate lazy var titleSectionView = makeTitleSectionView()
    fileprivate lazy var doneButton = makeDoneButton()

    fileprivate lazy var donateTapGestureRecognizer = UITapGestureRecognizer()
    fileprivate lazy var donateButtonView = makeDonateTapView()

    fileprivate lazy var reportSymptomsButton = makeButton(title: R.string.localizable.symptoms().localizedUppercase)
    fileprivate lazy var reportBehaviorsButton = makeButton(title: R.string.localizable.behaviors().localizedUppercase)

    fileprivate lazy var apiDataButton = makeButton(title: "API")
    fileprivate lazy var exportDataButton = makeButton(title: R.string.localizable.export().localizedUppercase)
    fileprivate lazy var deleteDataButton = makeButton(title: R.string.localizable.delete().localizedUppercase)

    fileprivate lazy var signOutButton = makeButton(title: R.string.localizable.sign_out().localizedUppercase)
    fileprivate lazy var recoverykeyButton = makeButton(title: R.string.localizable.recoveryKey().localizedUppercase)

    fileprivate lazy var faqButton = makeButton(title: R.string.localizable.faQ().localizedUppercase)
    fileprivate lazy var contactButton = makeButton(title: R.string.localizable.contact().localizedUppercase)

    fileprivate lazy var versionLabel = makeVersionLabel()
    fileprivate lazy var bitmarkCertView = makeBitmarkCertView()

    override func bindViewModel() {
        super.bindViewModel()

        donateTapGestureRecognizer.rx.event.bind { [weak self] _ in
            self?.gotoDonateScreen()
        }.disposed(by: disposeBag)

        doneButton.rx.tap.bind { [weak self] in
            self?.navigator.pop(sender: self, animationType: .slide(direction: .up))
        }.disposed(by: disposeBag)

        reportSymptomsButton.rx.tap.bind { [weak self] in
            self?.gotoReportSymptomsScreen()
        }.disposed(by: disposeBag)

        reportBehaviorsButton.rx.tap.bind { [weak self] in
            self?.gotoReportBehaviorsScreen()
        }.disposed(by: disposeBag)

        recoverykeyButton.rx.tap.bind { [weak self] in
            self?.gotoViewRecoveryKeyFlow()
        }.disposed(by: disposeBag)

        signOutButton.rx.tap.bind { [weak self] in
            self?.gotoSignOutWarningFlow()
        }.disposed(by: disposeBag)

        contactButton.rx.tap.bind { [weak self] in
            self?.showIntercomContact()
        }.disposed(by: disposeBag)
    }

    override func setupViews() {
        super.setupViews()

        Global.current.locationManager.requestAlwaysAuthorization()

        let reportSectionView = makeSectionView(
            title: R.string.localizable.report(),
            buttons: [reportSymptomsButton, reportBehaviorsButton])

        let dataSectionView = makeSectionView(
            title: R.string.localizable.data(),
            buttons: [apiDataButton, exportDataButton, deleteDataButton])

        let securitySectionView = makeSectionView(
            title: R.string.localizable.security(),
            buttons: [signOutButton, recoverykeyButton])

        let supportSectionView = makeSectionView(
            title: R.string.localizable.support(),
            buttons: [faqButton, contactButton])

        let settingsContentView = LinearView(
            items: [
                (reportSectionView, 0),
                (dataSectionView, 0),
                (securitySectionView, 0),
                (supportSectionView, 0)
            ], bottomConstraint: true)

        contentScrollView.addSubview(titleSectionView)
        contentScrollView.addSubview(donateButtonView)
        contentScrollView.addSubview(settingsContentView)
        contentScrollView.addSubview(bitmarkCertView)

        titleSectionView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
                .inset(OurTheme.profilePaddingInset)
        }

        donateButtonView.snp.makeConstraints { (make) in
            make.top.equalTo(titleSectionView.snp.bottom).offset(39)
            make.leading.trailing.equalToSuperview()

        }

        settingsContentView.snp.makeConstraints { (make) in
            make.top.equalTo(donateButtonView.snp.bottom).offset(30)
            make.width.equalToSuperview().offset(-30)
            make.leading.trailing.equalToSuperview()
                .inset(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        }

        bitmarkCertView.snp.makeConstraints { (make) in
            make.top.equalTo(settingsContentView.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview()
        }

        scrollView.addSubview(contentScrollView)
        contentView.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        contentScrollView.snp.makeConstraints { (make) in
            make.width.equalTo(contentView)
            make.top.bottom.leading.equalToSuperview()
        }
    }
}

// MARK: UITextViewDelegate
extension ProfileViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard URL.scheme != nil, let host = URL.host else {
            return false
        }

        guard let appLink = AppLink(rawValue: host),
            let appLinkURL = appLink.websiteURL
        else {
            return false
        }

        navigator.show(segue: .safariController(appLinkURL), sender: self, transition: .alert)
        return true
    }
}

// MARK: Navigator
extension ProfileViewController {
    fileprivate func gotoDonateScreen() {
        navigator.show(segue: .donate, sender: self)
    }

    fileprivate func gotoReportSymptomsScreen() {
        let viewModel = ReportSymptomsViewModel()
        navigator.show(segue: .reportSymptoms(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoReportBehaviorsScreen() {
        let viewModel = ReportBehaviorsViewModel()
        navigator.show(segue: .reportBehaviors(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoViewRecoveryKeyFlow() {
        navigator.show(segue: .viewRecoveryKeyWarning, sender: self)
    }

    fileprivate func gotoSignOutWarningFlow() {
        navigator.show(segue: .signOutWarning, sender: self)
    }

    fileprivate func showIntercomContact() {
        Intercom.presentMessenger()
    }
}

// MARK: - Setup Views
extension ProfileViewController {
    fileprivate func makeTitleSectionView() -> UIView {
        let titleScreenLabel = makeTitleScreenLabel()

        let view = UIView()
        view.addSubview(titleScreenLabel)
        view.addSubview(doneButton)

        titleScreenLabel.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
        }

        doneButton.snp.makeConstraints { (make) in
            make.trailing.centerY.equalToSuperview()
        }

        return view
    }

    fileprivate func makeTitleScreenLabel() -> UILabel {
        let label = Label()
        label.apply(text: R.string.localizable.profile().localizedUppercase,
                    font: R.font.domaineSansTextLight(size: 36),
                    themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeDoneButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.profileCloseIcon(), for: .normal)

        button.snp.makeConstraints { (make) in
            make.height.width.equalTo(30)
        }

        return button
    }

    fileprivate func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero;
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }

    fileprivate func makeButton(title: String) -> UIButton {
        let button = RightIconButton(title: title, icon: R.image.nextSilverCircle30(), spacing: 15)
        button.apply(font: R.font.domaineSansTextLight(size: 14))
        return button
    }

    fileprivate func makeDonateTapView() -> UIView {
        let label = Label()
        label.adjustsFontSizeToFitWidth = true
        label.apply(text: R.string.localizable.helpKeepAutonomyFree().localizedUppercase,
                    font: R.font.domaineSansTextLight(size: 18),
                    themeStyle: .lightTextColor)

        let imageView = ImageView(image: R.image.nextSilverCircle30())

        let view = UIView()
        view.addSubview(label)
        view.addSubview(imageView)

        view.addGestureRecognizer(donateTapGestureRecognizer)
        view.isUserInteractionEnabled = true

        label.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
                .inset(UIEdgeInsets(top: 8, left: 15, bottom: 7, right: 15))
        }

        imageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
            make.leading.greaterThanOrEqualTo(label.snp.trailing).offset(10)
        }

        themeService.rx
            .bind({ $0.blueRibbonColor}, to: view.rx.backgroundColor)
            .disposed(by: disposeBag)

        return view
    }

    fileprivate func makeButtonsView(buttons: [UIButton]) -> UIView {
        let view = UIView()

        for button in buttons {
            view.addSubview(button)
        }

        for (index, button) in buttons.enumerated() {
            switch index {
            case 0:
                button.snp.makeConstraints { (make) in
                    make.top.equalToSuperview()
                    make.trailing.equalToSuperview()
                    make.leading.greaterThanOrEqualToSuperview()
                }

            case 1..<buttons.count:
                let previousItem = buttons[index - 1]
                button.snp.makeConstraints { (make) in
                    make.top.equalTo(previousItem.snp.bottom)
                    make.trailing.equalToSuperview()
                    make.leading.greaterThanOrEqualToSuperview()
                }

            default:
                break
            }
        }

        buttons.last?.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
        }

        return view
    }

    fileprivate func makeSectionView(title: String, buttons: [UIButton]) -> UIView {
        let titleLabel = Label()
        titleLabel.apply(
            text: title,
            font: R.font.atlasGroteskLight(size: 24),
            themeStyle: .lightTextColor)

        let buttonsView = makeButtonsView(buttons: buttons)

        let contentView = UIView()
        contentView.addSubview(titleLabel)
        contentView.addSubview(buttonsView)

        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5)
            make.leading.equalToSuperview()
        }

        buttonsView.snp.makeConstraints { (make) in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing)
        }

        let separateLine = SeparateLine(height: 1, themeStyle: .separateTextColor)

        let view = UIView()
        view.addSubview(separateLine)
        view.addSubview(contentView)

        separateLine.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview()
        }

        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(separateLine.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-45)
        }

        return view
    }

    fileprivate func makeBitmarkCertView() -> UIView {
        let digitalRightsTextView = makeDigitalRightsTextView()
        let securedByBitmarkImage = ImageView(image: R.image.securedByBitmark())

        let view = UIView()
        view.addSubview(versionLabel)
        view.addSubview(digitalRightsTextView)
        view.addSubview(securedByBitmarkImage)

        versionLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(21)
            make.centerX.equalToSuperview()
        }

        digitalRightsTextView.snp.makeConstraints { (make) in
            make.top.equalTo(versionLabel.snp.bottom).offset(13)
            make.centerX.equalToSuperview()
        }

        securedByBitmarkImage.snp.makeConstraints { (make) in
            make.top.equalTo(digitalRightsTextView.snp.bottom).offset(17)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
        }

        themeService.rx
            .bind({ $0.mineShaftBackground }, to: view.rx.backgroundColor)
            .disposed(by: disposeBag)

        return view
    }

    fileprivate func makeVersionLabel() -> Label {
        let appVersion = Bundle.main.infoDictionary?[Constant.SettingsBundle.Keys.kVersion] ?? ""
        let bundleVersion = Bundle.main.infoDictionary?[Constant.SettingsBundle.Keys.kBundle] ?? ""

        let appVersionText = "\(appVersion) (\(bundleVersion))"

        let label = Label()
        label.apply(
            text: R.string.localizable.versionWithNumber(appVersionText),
            font: R.font.atlasGroteskLight(size: 14),
            themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeDigitalRightsTextView() -> UITextView {
        let textColor = themeService.attrs.concordColor

        let styleGroup: StyleXML = {
            let style = Style {
                $0.font = R.font.atlasGroteskLight(size: 14)
                $0.color = textColor
            }

            let digitalRights = Style {
                $0.linkURL = AppLink.digitalRights.appURL
                $0.underline = (NSUnderlineStyle.single, textColor)
            }

            return StyleXML(base: style, [
                "digital-rights": digitalRights
            ])
        }()

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
        textView.attributedText = R.string.phrase.launchDigitalRights()
                                   .set(style: styleGroup)
        return textView
    }
}
