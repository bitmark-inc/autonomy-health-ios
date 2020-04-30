//
//  AskInfoViewController.swift
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

class AskInfoViewController: ViewController, BackNavigator, PanModalDelegate {

    // MARK: - Properties
    fileprivate lazy var headerScreen = makeHeaderScreen()
    fileprivate lazy var titleScreen = makeTitleScreen()
    fileprivate lazy var infoTextView = makeInfoTextView()
    fileprivate lazy var backButton = makeLightBackItem()
    fileprivate lazy var nextButton = makeNextButton()
    fileprivate lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: nextButton)
    }()
    fileprivate var groupBottomConstraint: Constraint?

    fileprivate lazy var thisViewModel: AskInfoViewModel = {
        return viewModel as! AskInfoViewModel
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Outputs
    fileprivate var newSymptom: Symptom?
    fileprivate var newBehavior: Behavior?

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

    // MARK: - bindViewModel
    override func bindViewModel() {
        super.bindViewModel()

        _ = infoTextView.rx.textInput => thisViewModel.infoTextRelay

        switch thisViewModel.askInfoType {
        case .symptomTitle, .behaviorTitle:
            thisViewModel.infoTextRelay
                .map { $0.isNotEmpty }
                .bind(to: nextButton.rx.isEnabled)
                .disposed(by: disposeBag)
        default:
            nextButton.isEnabled = true
        }

        thisViewModel.submitSymptomResultSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (event) in
                guard let self = self else { return }
                loadingState.onNext(.hide)
                switch event {
                case .error(let error):
                    self.errorWhenSubmit(error: error)
                case .next(let symptom):
                    self.newSymptom = symptom
                    Global.log.info("[done] added new symptom")
                    self.showSubmittedPanModel()
                default:
                    break
                }
            }).disposed(by: disposeBag)

        thisViewModel.submitBehavorResultSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (event) in
                guard let self = self else { return }
                loadingState.onNext(.hide)
                switch event {
                case .error(let error):
                    self.errorWhenSubmit(error: error)
                case .next(let behavior):
                    self.newBehavior = behavior
                    Global.log.info("[done] added new behavior")
                    self.showSubmittedPanModel()
                default:
                    break
                }
            }).disposed(by: disposeBag)

        nextButton.rxTap.bind { [weak self] in
            self?.gotoNextAskInfoScreen()
        }.disposed(by: disposeBag)
    }

    fileprivate func showSubmittedPanModel() {
        let viewController = SuccessPanViewController()
        viewController.headerScreen.header = R.string.localizable.added().localizedUppercase

        switch thisViewModel.askInfoType {
        case .symptomTitle, .symptomDesc:
            viewController.titleLabel.setText(R.string.phrase.addSymptomThankTitle().localizedUppercase)
            viewController.descLabel.setText(R.string.phrase.addSymptomThankDesc())

        case .behaviorTitle, .behaviorDesc:
            viewController.titleLabel.setText(R.string.phrase.addBehaviorThankTitle().localizedUppercase)
            viewController.descLabel.setText(R.string.phrase.addBehaviorThankDesc())
        default:
            break
        }

        viewController.gotItButton.titleLabel.setText(R.string.localizable.ok().localizedUppercase)
        viewController.delegate = self
        presentPanModal(viewController)
    }

    /// pass newSymptom / newBehavior into parentViewController;
    /// then back to parentViewController
    func donePanModel() {
        infoTextView.resignFirstResponder()

        // pop 2 viewControllers (title & desc)
        guard let navigationController = self.navigationController else { return }
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]

        let parentViewController = viewControllers[viewControllers.count - 3]

        switch thisViewModel.askInfoType {
        case .symptomDesc:
            guard let surveySymptomsVC = parentViewController as? SurveySymptomsViewController,
                let newSymptom = newSymptom else {
                    return
            }
            surveySymptomsVC.newSymptomSubject.onNext(newSymptom)

        case .behaviorDesc:
            guard let surveyBehaviorsVC = parentViewController as? SurveyBehaviorsViewController,
                let newBehavior = newBehavior else {
                    return
            }
            surveyBehaviorsVC.newBehaviorSubject.onNext(newBehavior)

        default:
            break
        }

        navigationController.popToViewController(parentViewController, animated: true)
    }

    // MARK: - Error Handlers
    fileprivate func errorWhenSubmit(error: Error) {
        guard !AppError.errorByNetworkConnection(error),
            !handleErrorIfAsAFError(error),
            !showIfRequireUpdateVersion(with: error) else {
                return
        }

        Global.log.error(error)
        showErrorAlertWithSupport(message: R.string.error.system())
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
                (infoTextView, Size.dh(44))],
            bottomConstraint: true)

        contentView.addSubview(paddingContentView)
        contentView.addSubview(groupsButton)

        titleScreen.snp.makeConstraints { (make) in
            make.height.equalTo(contentView).multipliedBy(OurTheme.titleHeight)
        }

        paddingContentView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
                .inset(OurTheme.paddingInset)
        }

        groupsButton.snp.makeConstraints { (make) in
            make.top.equalTo(paddingContentView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview()
            groupBottomConstraint = make.bottom.equalToSuperview().constraint
        }
    }
}

// MARK: - KeyboardObserver
extension AskInfoViewController {
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
extension AskInfoViewController {
    fileprivate func gotoNextAskInfoScreen() {
        guard var survey = thisViewModel.survey else { return }

        switch thisViewModel.askInfoType {
        case .symptomTitle:
            survey.name = thisViewModel.infoTextRelay.value
            let viewModel = AskInfoViewModel(askInfoType: .symptomDesc, survey: survey)
            navigator.show(segue: .askInfo(viewModel: viewModel), sender: self)

        case .symptomDesc:
            survey.desc = thisViewModel.infoTextRelay.value
            infoTextView.endEditing(true)
            thisViewModel.submitSymptom(survey)

        case .behaviorTitle:
            survey.name = thisViewModel.infoTextRelay.value
            let viewModel = AskInfoViewModel(askInfoType: .behaviorDesc, survey: survey)
            navigator.show(segue: .askInfo(viewModel: viewModel), sender: self)

        case .behaviorDesc:
            survey.desc = thisViewModel.infoTextRelay.value
            infoTextView.endEditing(true)
            thisViewModel.submitBehavior(survey)

        case .none:
            break
        }
    }
}

// MARK: - Setup views
extension AskInfoViewController {
    fileprivate func makeHeaderScreen() -> HeaderView {
        var headerString = ""

        switch thisViewModel.askInfoType {
        case .symptomTitle, .symptomDesc:
            headerString = R.string.localizable.symptom().localizedUppercase
        case .behaviorTitle, .behaviorDesc:
            headerString = R.string.localizable.behavior().localizedUppercase
        default:
            break
        }

        return HeaderView(header: headerString)
    }

    fileprivate func makeTitleScreen() -> CenterView {
        let label = Label()
        label.numberOfLines = 0

        var titleText: String = ""
        switch thisViewModel.askInfoType {
        case .symptomTitle:     titleText = R.string.phrase.addSymptomFormName()
        case .symptomDesc:      titleText = R.string.phrase.addSymptomFormDesc()
        case .behaviorTitle:    titleText = R.string.phrase.addBehaviorFormName()
        case .behaviorDesc:     titleText = R.string.phrase.addBehaviorFormDesc()
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
        switch thisViewModel.askInfoType {
        case .symptomTitle:  placeholderText = R.string.phrase.addSymptomFormNamePlaceholder()
        case .symptomDesc:   placeholderText = R.string.phrase.addSymptomFormDescPlaceholder()
        case .behaviorTitle: placeholderText = R.string.phrase.addBehaviorFormNamePlaceholder()
        case .behaviorDesc:  placeholderText = R.string.phrase.addBehaviorFormDescPlaceholder()
        case .none:
            break
        }

        textView.apply(placeholder: placeholderText, font: R.font.atlasGroteskLight(size: 18))
        textView.autocorrectionType = .no
        return textView
    }

    fileprivate func makeNextButton() -> SubmitButton {
        switch thisViewModel.askInfoType {
        case .symptomTitle, .behaviorTitle:
            return SubmitButton(
                title: R.string.localizable.next().localizedUppercase,
                icon: R.image.nextCircleArrow()!)
        case .symptomDesc, .behaviorDesc, .none:
            return SubmitButton(
                title: R.string.localizable.done().localizedUppercase,
                icon: R.image.doneCircleArrow()!)
        }
    }
}
