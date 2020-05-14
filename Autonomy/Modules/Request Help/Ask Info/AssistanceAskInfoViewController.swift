//
//  AssistanceAskInfoViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/30/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import KMPlaceholderTextView

class AssistanceAskInfoViewController: ViewController, BackNavigator {

    // MARK: - Properties
    lazy var headerScreen: UIView = {
        HeaderView(header: R.string.localizable.assistance().localizedUppercase)
    }()
    lazy var titleScreen = makeTitleScreen()
    lazy var infoTextView = makeInfoTextView()
    lazy var backButton = makeLightBackItem()
    lazy var nextButton = makeNextButton()
    lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: nextButton)
    }()
    var groupBottomConstraint: Constraint?

    lazy var thisViewModel: AssistanceAskInfoViewModel = {
        return viewModel as! AssistanceAskInfoViewModel
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - bindViewModel
    override func bindViewModel() {
        super.bindViewModel()

        _ = infoTextView.rx.textInput => thisViewModel.infoTextRelay

        thisViewModel.infoTextRelay
            .map { $0.isNotEmpty }
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)

        nextButton.rx.tap.bind { [weak self] in
            self?.gotoNextAskInfoScreen()
        }.disposed(by: disposeBag)
    }

    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Register Keyboard Notification
        addNotificationObserver(name: UIWindow.keyboardWillShowNotification, selector: #selector(keyboardWillBeShow))
        addNotificationObserver(name: UIWindow.keyboardWillHideNotification, selector: #selector(keyboardWillBeHide))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        infoTextView.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        infoTextView.endEditing(true)
        removeNotificationsObserver()
    }

    // MARK: - Setup views
    override func setupViews() {
        super.setupViews()

        // *** Setup subviews ***
        let paddingContentView = LinearView(
            items: [
                (headerScreen, 0),
                (titleScreen, 0),
                (SeparateLine(height: 1), 3),
                (infoTextView, Size.dh(44))
            ]
        )

        paddingContentView.addSubview(groupsButton)

        infoTextView.snp.makeConstraints { (make) in
            make.bottom.equalTo(groupsButton.snp.top).offset(-15)
        }

        groupsButton.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            groupBottomConstraint = make.bottom.equalToSuperview().constraint
        }

        contentView.addSubview(paddingContentView)
        titleScreen.snp.makeConstraints { (make) in
            make.height.equalTo(OurTheme.titleHeight)
        }

        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(OurTheme.paddingInset)
        }
    }
}

// MARK: - KeyboardObserver
extension AssistanceAskInfoViewController {
    @objc func keyboardWillBeShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        groupBottomConstraint?.update(offset: -keyboardSize.height)
        view.layoutIfNeeded()
    }

    @objc func keyboardWillBeHide(notification: Notification) {
        groupBottomConstraint?.update(offset: 0)
        view.layoutIfNeeded()
    }
}

// MARK: - Navigator
extension AssistanceAskInfoViewController {
    fileprivate func gotoNextAskInfoScreen() {
        guard var helpRequest = thisViewModel.helpRequest else { return }
        switch thisViewModel.assistanceInfoType {
        case .exactNeeds:
            helpRequest.exactNeeds = thisViewModel.infoTextRelay.value
            let viewModel = AssistanceAskInfoViewModel(assistanceInfoType: .meetingLocation, helpRequest: helpRequest)
            navigator.show(segue: .assistanceAskInfo(viewModel: viewModel), sender: self)

        case .meetingLocation:
            helpRequest.meetingLocation = thisViewModel.infoTextRelay.value
            let viewModel = AssistanceAskInfoViewModel(assistanceInfoType: .contactInfo, helpRequest: helpRequest)
            navigator.show(segue: .assistanceAskInfo(viewModel: viewModel), sender: self)

        case .contactInfo:
            helpRequest.contactInfo = thisViewModel.infoTextRelay.value
            helpRequest.createdAt = Date()
            let viewModel = ReviewHelpRequestViewModel(helpRequest: helpRequest)
            navigator.show(segue: .reviewHelpRequest(viewModel: viewModel), sender: self)

        case .none:
            break
        }
    }
}

// MARK: - Setup views
extension AssistanceAskInfoViewController {
    fileprivate func makeTitleScreen() -> CenterView {
        let label = Label()
        label.numberOfLines = 0

        var titleText: String = ""
        switch thisViewModel.assistanceInfoType {
        case .exactNeeds:       titleText = R.string.phrase.assistanceNeedItemsTitle()
        case .meetingLocation:  titleText = R.string.phrase.assistancePlaceTitle()
        case .contactInfo:      titleText = R.string.phrase.assistanceContactTitle()
        case .none:
            break
        }

        label.apply(text: titleText,
                    font: R.font.atlasGroteskLight(size: Size.ds(36)),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return CenterView(contentView: label)
    }

    fileprivate func makeInfoTextView() -> PlaceholderTextView {
        let textView = PlaceholderTextView()

        var placeholderText: String = ""
        switch thisViewModel.assistanceInfoType {
        case .exactNeeds:       placeholderText = R.string.phrase.assistanceNeedItemsPlaceholder()
        case .meetingLocation:  placeholderText = R.string.phrase.assistancePlacePlaceholder()
        case .contactInfo:      placeholderText = R.string.phrase.assistanceContactPlaceholder()
        case .none:
            break
        }

        textView.apply(placeholder: placeholderText, font: R.font.atlasGroteskLight(size: 18))
        textView.autocorrectionType = .no
        return textView
    }

    fileprivate func makeNextButton() -> RightIconButton {
        switch thisViewModel.assistanceInfoType {
        case .exactNeeds, .meetingLocation:
            return RightIconButton(
                title: R.string.localizable.next().localizedUppercase,
                icon: R.image.nextCircleArrow()!)
        case .contactInfo, .none:
            return RightIconButton(
                title: R.string.localizable.review().localizedUppercase,
                icon: R.image.nextCircleArrow()!)
        }
    }
}
