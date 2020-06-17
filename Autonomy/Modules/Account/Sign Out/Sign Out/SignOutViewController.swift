//
//  SignOutViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/17/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import KMPlaceholderTextView

class SignOutViewController: ViewController, BackNavigator {

    // MARK: - Properties
    fileprivate lazy var headerScreen: UIView = {
        HeaderView(header: R.string.localizable.signOut().localizedUppercase)
    }()
    fileprivate lazy var titleLabel = makeTitleLabel()
    fileprivate lazy var textView = makeTextView()

    fileprivate lazy var backButton = makeLightBackItem()
    fileprivate lazy var signOutButton = RightIconButton(title:R.string.localizable.signOut().localizedUppercase,
                                                      icon: R.image.signoutButton())
    fileprivate lazy var groupsButton: UIView = {
        let groupView = ButtonGroupView(button1: backButton, button2: signOutButton, hasGradient: false)
        groupView.apply(backgroundStyle: .codGrayBackground)
        return groupView
    }()
    fileprivate var groupBottomConstraint: Constraint?

    fileprivate weak var errorPanModalVC: ActionPanViewController?
    fileprivate weak var panModalVC: ProgressPanViewController?

    fileprivate lazy var thisViewModel: SignOutViewModel = {
        return viewModel as! SignOutViewModel
    }()

    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Register Keyboard Notification
        addNotificationObserver(name: UIWindow.keyboardWillShowNotification, selector: #selector(keyboardWillBeShow))
        addNotificationObserver(name: UIWindow.keyboardWillHideNotification, selector: #selector(keyboardWillBeHide))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        textView.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeNotificationsObserver()
    }

    override func bindViewModel() {
        super.bindViewModel()

        _ = textView.rx.textInput => thisViewModel.phrasesTextRelay

        thisViewModel.submitEnabled
            .drive(signOutButton.rx.isEnabled)
            .disposed(by: disposeBag)

        thisViewModel.signOutResultSubject
            .subscribe(onNext: { [weak self] (event) in
                loadingState.onNext(.hide)
                self?.panModalVC?.dismiss(animated: true, completion: { [weak self] in
                    guard let self = self else { return }

                    switch event {
                    case .error(_):
                        self.errorWhenSignOut()
                    case .completed:
                        Global.log.info("[done] signOut Account")
                        self.gotoOnboardingScreen()
                    default:
                        break
                    }
                })
            }).disposed(by: disposeBag)

        signOutButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            guard self.thisViewModel.validRecoveryKey() else {
                self.errorWhenSignOut()
                return
            }

            self.showProgressPanModal()
            self.thisViewModel.signOut()
        }.disposed(by: disposeBag)
    }

    fileprivate func errorWhenSignOut() {
        textView.resignFirstResponder()

        let viewController = ActionPanViewController()
        viewController.headerScreen.header = R.string.localizable.error().localizedUppercase
        viewController.titleLabel.setText(R.string.error.signOutTitle().localizedUppercase)
        viewController.messageLabel.setText(R.string.error.signOutMessage())

        viewController.action1Button.setTitle(R.string.localizable.checkKey().localizedUppercase, for: .normal)
        viewController.action1Button.rx.tap.bind { [weak self] in
            self?.authAndGotoViewRecoveryKeyScreen()
        }.disposed(by: disposeBag)

        viewController.action2Button.setTitle(R.string.localizable.tryAgain().localizedUppercase, for: .normal)
        viewController.action2Button.rx.tap.bind {
            viewController.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)

        presentPanModal(viewController)

        errorPanModalVC = viewController
    }

    fileprivate func showProgressPanModal() {
        textView.resignFirstResponder()

        let viewController = ProgressPanViewController()
        viewController.headerScreen.header = R.string.localizable.signingOut().localizedUppercase
        viewController.titleLabel.setText(R.string.phrase.signOutProcessing())
        presentPanModal(viewController)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewController.indeterminateProgressBar.startAnimating()
        }

        panModalVC = viewController
    }

    override func setupViews() {
        super.setupViews()

        // *** Setup subviews ***
        let paddingContentView = LinearView(
            items: [
                (headerScreen, 0),
                (titleLabel, 0),
                (SeparateLine(height: 1), 3),
                (textView, Size.dh(44))
            ],
            bottomConstraint: true
        )

        paddingContentView.addSubview(groupsButton)

        contentView.addSubview(paddingContentView)
        contentView.addSubview(groupsButton)

        titleLabel.snp.makeConstraints { (make) in
            make.height.equalTo(OurTheme.titleHeight)
        }

        paddingContentView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview().inset(OurTheme.paddingInset)
            make.bottom.equalTo(groupsButton.snp.top).offset(-15)
        }

        groupsButton.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            groupBottomConstraint = make.bottom.equalToSuperview().constraint
        }
    }
}

// MARK: - Navigator
extension SignOutViewController {
    fileprivate func authAndGotoViewRecoveryKeyScreen() {
        BiometricAuth.authorizeAccess()
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in
                guard let self = self else { return }
                self.errorPanModalVC?.dismiss(animated: true, completion: nil)
                self.gotoViewRecoveryKeyScreen()
            })
            .disposed(by: disposeBag)
    }

    fileprivate func gotoViewRecoveryKeyScreen() {
        let viewModel = ViewRecoveryKeyViewModel()
        navigator.show(segue: .viewRecoveryKey(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoOnboardingScreen() {
        navigator.show(segue: .signInWall, sender: self, transition: .replace(type: .none))
    }
}

// MARK: - Setup views
extension SignOutViewController {
    fileprivate func makeTitleLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.apply(text: R.string.phrase.signOutTitle(),
                    font: R.font.atlasGroteskLight(size: 36),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        return label
    }

    fileprivate func makeTextView() -> PlaceholderTextView {
        let textView = PlaceholderTextView()
        textView.apply(placeholder: R.string.phrase.signOutPlaceholder(),
                       font: R.font.atlasGroteskLight(size: 18))
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        return textView
    }
}

// MARK: - KeyboardObserver
extension SignOutViewController {
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
