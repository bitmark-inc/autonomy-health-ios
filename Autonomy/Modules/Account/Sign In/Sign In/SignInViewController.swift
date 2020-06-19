//
//  SignInViewController.swift
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

class SignInViewController: ViewController, BackNavigator, LaunchingNavigatorDelegate {

    // MARK: - Properties
    fileprivate lazy var headerScreen: UIView = {
        HeaderView(header: R.string.localizable.signIn().localizedUppercase)
    }()
    fileprivate lazy var titleLabel = makeTitleLabel()
    fileprivate lazy var textView = makeTextView()

    fileprivate lazy var backButton = makeLightBackItem()
    fileprivate lazy var signInButton = RightIconButton(title:R.string.localizable.signIn().localizedUppercase,
                                                      icon: R.image.signinButton())
    fileprivate lazy var groupsButton: UIView = {
        let groupView = ButtonGroupView(button1: backButton, button2: signInButton, hasGradient: false, button1SpacePercent: 0.4)
        groupView.apply(backgroundStyle: .codGrayBackground)
        return groupView
    }()
    fileprivate var groupBottomConstraint: Constraint?

    fileprivate weak var errorPanModalVC: ActionPanViewController?
    fileprivate weak var panModalVC: ProgressPanViewController?

    fileprivate lazy var thisViewModel: SignInViewModel = {
        return viewModel as! SignInViewModel
    }()

    var didAutoFocusTextField: Bool = false

    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Register Keyboard Notification
        addNotificationObserver(name: UIWindow.keyboardWillShowNotification, selector: #selector(keyboardWillBeShow))
        addNotificationObserver(name: UIWindow.keyboardWillHideNotification, selector: #selector(keyboardWillBeHide))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !didAutoFocusTextField else { return }
        didAutoFocusTextField = true
        textView.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        textView.resignFirstResponder()
        removeNotificationsObserver()
    }

    override func bindViewModel() {
        super.bindViewModel()

        _ = textView.rx.textInput => thisViewModel.phrasesTextRelay

        thisViewModel.submitEnabled
            .drive(signInButton.rx.isEnabled)
            .disposed(by: disposeBag)

        thisViewModel.signInResultSubject
            .subscribe(onNext: { [weak self] (event) in
                guard let self = self else { return }
                loadingState.onNext(.hide)

                switch event {
                case .error:
                    self.panModalVC?.dismiss(animated: true, completion: { [weak self] in
                        self?.errorWhenSignIn()
                    })
                case .next:
                    Global.log.info("[done] signIn Account")
                    self.navigate()
                default:
                    break
                }
            }).disposed(by: disposeBag)

        signInButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.showProgressPanModal()
            self.thisViewModel.signIn()
        }.disposed(by: disposeBag)
    }

    func gotoMainScreen() {
        panModalVC?.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            let viewModel = MainViewModel()
            self.navigator.show(segue: .main(viewModel: viewModel), sender: self,
                           transition: .replace(type: .slide(direction: .down)))
        })
    }

    deinit {
        panModalVC?.dismiss(animated: false, completion: nil)
        errorPanModalVC?.dismiss(animated: false, completion: nil)
    }

    fileprivate func errorWhenSignIn() {
        textView.resignFirstResponder()

        let viewController = ActionPanViewController()
        viewController.headerScreen.header = R.string.localizable.error().localizedUppercase
        viewController.titleLabel.setText(R.string.error.signInTitle().localizedUppercase)
        viewController.messageLabel.setText(R.string.error.signInMessage())

        viewController.action1Button.setTitle(R.string.localizable.cancel().localizedUppercase, for: .normal)
        viewController.action1Button.rx.tap.bind { [weak self] in
            viewController.dismiss(animated: true) { [weak self] in
                self?.navigator.pop(sender: self)
            }
        }.disposed(by: disposeBag)

        viewController.action2Button.setTitle(R.string.localizable.tryAgain().localizedUppercase, for: .normal)
        viewController.action2Button.rx.tap.bind { [weak self] in

            viewController.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                self.textView.becomeFirstResponder()
            }
        }.disposed(by: disposeBag)

        presentPanModal(viewController)
        errorPanModalVC = viewController
    }

    fileprivate func showProgressPanModal() {
        textView.resignFirstResponder()

        let viewController = ProgressPanViewController()
        viewController.headerScreen.header = R.string.localizable.signingIn().localizedUppercase
        viewController.titleLabel.setText(R.string.phrase.signInProcessing())
        presentPanModal(viewController)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewController.indeterminateProgressBar.startAnimating()
        }

        panModalVC = viewController
    }

    override func setupViews() {
        super.setupViews()

        // *** Setup subviews ***
        let titleCenterView = CenterView(contentView: titleLabel, shrink: true)
        let paddingContentView = LinearView(
            items: [
                (headerScreen, 0),
                (titleCenterView, 0),
                (SeparateLine(height: 1), 3),
                (textView, Size.dh(44))
            ],
            bottomConstraint: true
        )

        paddingContentView.addSubview(groupsButton)

        contentView.addSubview(paddingContentView)
        contentView.addSubview(groupsButton)

        titleCenterView.snp.makeConstraints { (make) in
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

// MARK: - Setup views
extension SignInViewController {
    fileprivate func makeTitleLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.apply(text: R.string.phrase.signInTitle(),
                    font: R.font.atlasGroteskLight(size: Size.ds(24)),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        return label
    }

    fileprivate func makeTextView() -> PlaceholderTextView {
        let textView = PlaceholderTextView()
        textView.apply(placeholder: R.string.phrase.signInPlaceholder(),
                       font: R.font.atlasGroteskLight(size: 18))
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        return textView
    }
}

// MARK: - KeyboardObserver
extension SignInViewController {
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
