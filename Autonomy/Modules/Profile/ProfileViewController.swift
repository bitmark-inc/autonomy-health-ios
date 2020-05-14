//
//  ProfileViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/28/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit

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

    fileprivate lazy var signOutButton = makeButton(title: R.string.localizable.signOut().localizedUppercase)
    fileprivate lazy var recoverykeyButton = makeButton(title: R.string.localizable.recoveryKey().localizedUppercase)

    fileprivate lazy var faqButton = makeButton(title: R.string.localizable.faQ().localizedUppercase)
    fileprivate lazy var contactButton = makeButton(title: R.string.localizable.contact().localizedUppercase)

    fileprivate lazy var versionLabel = makeVersionLabel()
    fileprivate lazy var bitmarkCertView = makeBitmarkCertView()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

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
    }

    override func setupViews() {
        super.setupViews()

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
            return true
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
        let viewModel = SurveySymptomsViewModel()
        navigator.show(segue: .surveySymptoms(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoSymptomHistoryScreen() {
        let viewModel = SymptomHistoryViewModel()
        navigator.show(segue: .symptomHistory(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoReportBehaviorsScreen() {
        let viewModel = SurveyBehaviorsViewModel()
        navigator.show(segue: .surveyBehaviors(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoBehaviorHistoryScreen() {
        let viewModel = BehaviorHistoryViewModel()
        navigator.show(segue: .behaviorHistory(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoLocationHistoryScreen() {
        let viewModel = LocationHistoryViewModel()
        navigator.show(segue: .locationHistory(viewModel: viewModel), sender: self)
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
        return RightIconButton(title: title, icon: R.image.nextSilverCircle30(), spacing: 15)
    }

    fileprivate func makeDonateTapView() -> UIView {
        let label = Label()
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
            make.trailing.lessThanOrEqualTo(imageView.snp.leading)
        }

        imageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
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
            make.top.leading.equalToSuperview()
        }

        buttonsView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(-15)
            make.bottom.trailing.equalToSuperview()
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
        let eulaAndPolicyTextView = makeEulaAndPolicyTextView()
        let securedByBitmarkImage = ImageView(image: R.image.securedByBitmark())

        let view = UIView()
        view.addSubview(versionLabel)
        view.addSubview(eulaAndPolicyTextView)
        view.addSubview(securedByBitmarkImage)

        versionLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(21)
            make.centerX.equalToSuperview()
        }

        eulaAndPolicyTextView.snp.makeConstraints { (make) in
            make.top.equalTo(versionLabel.snp.bottom).offset(13)
            make.centerX.equalToSuperview()
        }

        securedByBitmarkImage.snp.makeConstraints { (make) in
            make.top.equalTo(eulaAndPolicyTextView.snp.bottom).offset(17)
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

    fileprivate func makeEulaAndPolicyTextView() -> UITextView {
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
