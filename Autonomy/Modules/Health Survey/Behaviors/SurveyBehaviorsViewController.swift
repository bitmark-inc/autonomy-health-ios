//
//  SurveyBehaviorsViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/29/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SkeletonView

class SurveyBehaviorsViewController: ViewController, BackNavigator {

    // MARK: - Properties
    fileprivate lazy var headerScreen: UIView = {
        HeaderView(header: R.string.localizable.behaviors().localizedUppercase)
    }()
    fileprivate lazy var titleScreen = makeTitleScreen()
    fileprivate lazy var behaviorsScrollView = makeBehaviorsScrollView()
    fileprivate lazy var behaviorViewsStack = UIStackView()
    fileprivate lazy var addNewBehaviorView = makeAddNewBehaviorView()

    fileprivate lazy var backButton = makeLightBackItem()
    fileprivate lazy var doneButton = SubmitButton(title: R.string.localizable.submit().localizedUppercase,
                                       icon: R.image.upCircleArrow()!)
    fileprivate lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: doneButton, hasGradient: false)
    }()

    fileprivate lazy var thisViewModel: SurveyBehaviorsViewModel = {
        return viewModel as! SurveyBehaviorsViewModel
    }()

    fileprivate var behaviors = [Behavior]()
    var newBehaviorSubject = PublishSubject<Behavior>()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - bindViewModel
    override func bindViewModel() {
        super.bindViewModel()

        thisViewModel.fetchDataResultSubject
            .subscribe(onNext: { [weak self] (event) in
                guard let self = self else { return }
                switch event {
                case .error(let error):
                    self.errorWhenFetchingData(error: error)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        thisViewModel.behaviorsRelay
            .filterNil()
            .subscribe(onNext: { [weak self] (behaviors) in
                guard let self = self else { return }
                self.behaviors = behaviors
                self.rebuilBehaviorsScrollView()
            })
            .disposed(by: disposeBag)

        thisViewModel.surveySubmitResultSubject
            .subscribe(onCompleted: { [weak self] in
                loadingState.onNext(.hide)
                self?.showSignedPanModel()
            })
            .disposed(by: disposeBag)

        doneButton.rxTap.bind { [weak self] in
            guard let self = self else { return }
            loadingState.onNext(.processing)
            let selectedBehaviorKeys = self.getSelectedBehaviorKeys()
            self.thisViewModel.report(with: selectedBehaviorKeys)
        }.disposed(by: disposeBag)

        newBehaviorSubject
            .subscribe(onNext: { [weak self] (behavior) in
                guard let self = self else { return }
                self.behaviors.append(behavior)
                self.behaviorViewsStack.addArrangedSubview(CheckboxView(title: behavior.name, description: behavior.desc))
            })
            .disposed(by: disposeBag)
    }

    fileprivate func showSignedPanModel() {
        let viewController = SuccessPanViewController()
        viewController.headerScreen.header = R.string.localizable.reported().localizedUppercase
        viewController.titleLabel.setText(R.string.phrase.behaviorsReportedTitle().localizedUppercase)
        viewController.descLabel.setText(R.string.phrase.behaviorsReportedDesc())
        viewController.gotItButton.titleLabel.setText(R.string.localizable.ok().localizedUppercase)
        viewController.delegate = self
        presentPanModal(viewController)
    }

    func getSelectedBehaviorKeys() -> [String] {
        guard let behaviorViews = behaviorViewsStack.arrangedSubviews as? [CheckboxView] else {
            return []
        }

        return behaviors.enumerated().compactMap { (index, behavior) -> String? in
            let behaviorCheckView = behaviorViews[index]
            return behaviorCheckView.checkBox.on ? behavior.id : nil
        }
    }

    fileprivate func rebuilBehaviorsScrollView() {
        behaviorViewsStack = UIStackView(
            arrangedSubviews: behaviors.map { CheckboxView(title: $0.name, description: $0.desc) },
            axis: .vertical, spacing: 15)

        behaviorsScrollView.removeSubviews()
        behaviorsScrollView.addSubview(behaviorViewsStack)
        behaviorsScrollView.addSubview(addNewBehaviorView)

        behaviorViewsStack.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
        }

        addNewBehaviorView.snp.makeConstraints { (make) in
            make.top.equalTo(behaviorViewsStack.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - Error Handlers
    func errorWhenFetchingData(error: Error) {
        guard !AppError.errorByNetworkConnection(error),
            !showIfRequireUpdateVersion(with: error),
            !handleErrorIfAsAFError(error) else {
                return
        }

        Global.log.error(error)
        showErrorAlertWithSupport(message: R.string.error.system())
    }

    fileprivate func errorWhenReport(error: Error) {
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
                (SeparateLine(height: 1), 3)],
            bottomConstraint: true)

        contentView.addSubview(paddingContentView)
        contentView.addSubview(behaviorsScrollView)
        contentView.addSubview(groupsButton)

        titleScreen.snp.makeConstraints { (make) in
            make.height.equalTo(contentView).multipliedBy(OurTheme.titleHeight)
        }

        paddingContentView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
                .inset(OurTheme.paddingOverBottomInset)
        }

        behaviorsScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(paddingContentView.snp.bottom).offset(13)
            make.leading.trailing.equalToSuperview()
        }

        groupsButton.snp.makeConstraints { (make) in
            make.top.equalTo(behaviorsScrollView.snp.bottom).offset(3)
            make.leading.trailing.bottom.equalToSuperview()
        }

        sampleBehaviorsScrollView()
    }
}

// MARK: - PanModalDelegate
extension SurveyBehaviorsViewController: PanModalDelegate {
    func donePanModel() {

        if let navViewControllers = navigationController?.viewControllers {
            let leadingViewController = navViewControllers[navViewControllers.count - 2]

            if type(of: leadingViewController) == BehaviorHistoryViewController.self {
                Navigator.default.pop(sender: self)
                return
            }
        }

        gotoMainScreen()
    }
}

// MARK: - Navigator
extension SurveyBehaviorsViewController {
    fileprivate func gotoMainScreen() {
        let viewModel = MainViewModel()
        navigator.show(segue: .main(viewModel: viewModel), sender: self,
                       transition: .replace(type: .slide(direction: .down)))
    }

    fileprivate func gotoAddNewBehavior() {
        let survey = Survey()
        let viewModel = AskInfoViewModel(askInfoType: .behaviorTitle, survey: survey)
        navigator.show(segue: .askInfo(viewModel: viewModel), sender: self)
    }
}

// MARK: - Setup views
extension SurveyBehaviorsViewController {
    fileprivate func makeTitleScreen() -> CenterView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.surveyBehaviorsTitle(),
                    font: R.font.atlasGroteskLight(size: Size.ds(36)),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return CenterView(contentView: label, shrink: true)
    }

    fileprivate func makeAddNewBehaviorView() -> UIView {
        let addNewView = AddRow(title: R.string.phrase.addBehaviorAdd())

        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event.bind { [weak self] (_) in
            self?.gotoAddNewBehavior()
        }.disposed(by: disposeBag)

        addNewView.addGestureRecognizer(tapGesture)
        return addNewView
    }

    fileprivate func makeBehaviorsScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.contentInset = OurTheme.paddingInset
        scrollView.isSkeletonable = true
        return scrollView
    }

    fileprivate func sampleBehaviorsScrollView() {
        let behaviorViews = (0...3).map { (_) -> CheckboxView in
            return CheckboxView(title: Constant.fieldPlaceholder, description: Constant.fieldPlaceholder)
        }

        let behaviorViewsStack = UIStackView(arrangedSubviews: behaviorViews, axis: .vertical, spacing: 15)
        behaviorViewsStack.isSkeletonable = true
        behaviorViewsStack.showAnimatedSkeleton(usingColor: Constant.skeletonColor)

        behaviorsScrollView.removeSubviews()
        behaviorsScrollView.addSubview(behaviorViewsStack)

        behaviorViewsStack.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
        }
    }
}
