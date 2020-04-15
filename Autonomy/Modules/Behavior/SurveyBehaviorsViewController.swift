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
    lazy var headerScreen: UIView = {
        HeaderView(header: R.string.localizable.behaviors().localizedUppercase)
    }()
    lazy var titleScreen = makeTitleScreen()
    lazy var behaviorsScrollView = makeBehaviorsScrollView()

    lazy var backButton = makeLightBackItem()
    lazy var doneButton = SubmitButton(title: R.string.localizable.submit().localizedUppercase,
                                       icon: R.image.upCircleArrow()!)
    lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: doneButton, hasGradient: false)
    }()

    lazy var thisViewModel: SurveyBehaviorsViewModel = {
        return viewModel as! SurveyBehaviorsViewModel
    }()

    var behaviors = [Behavior]()
    var behaviorViews = [CheckboxView]()

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
            .subscribe(onNext: { [weak self] (event) in
                guard let self = self else { return }
                loadingState.onNext(.hide)
                switch event {
                case .error(let error):
                    self.errorWhenFetchingData(error: error)

                case .completed:
                    Global.log.info("[behaviors] report successfully")
                    self.showSignedPanModel()
                default:
                    break
                }

            })
            .disposed(by: disposeBag)

        doneButton.rxTap.bind { [weak self] in
            guard let self = self else { return }
            let selectedBehaviorKeys = self.getSelectedBehaviorKeys()
        }.disposed(by: disposeBag)
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
        return behaviors.enumerated().compactMap { (index, behavior) -> String? in
            let behaviorCheckView = behaviorViews[index]
            return behaviorCheckView.checkBox.on ? behavior.id : nil
        }
    }

    fileprivate func rebuilBehaviorsScrollView() {
        behaviorViews = behaviors.map { (behavior) -> CheckboxView in
            return CheckboxView(title: behavior.name, description: behavior.desc)
        }

        let behaviorViewsStack = UIStackView(arrangedSubviews: behaviorViews, axis: .vertical, spacing: 15)

        behaviorsScrollView.removeSubviews()
        behaviorsScrollView.addSubview(behaviorViewsStack)

        behaviorViewsStack.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
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

    fileprivate func makeBehaviorsScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.contentInset = OurTheme.paddingInset
        scrollView.isSkeletonable = true
        return scrollView
    }

    fileprivate func sampleBehaviorsScrollView() {
        let behaviorViews = (0...3).map { (_) -> CheckboxView in
            return CheckboxView(title: "---", description: "---")
        }

        let behaviorViewsStack = UIStackView(arrangedSubviews: behaviorViews, axis: .vertical, spacing: 15)
        behaviorViewsStack.isSkeletonable = true
        behaviorViewsStack.showAnimatedSkeleton()

        behaviorsScrollView.removeSubviews()
        behaviorsScrollView.addSubview(behaviorViewsStack)

        behaviorViewsStack.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
        }
    }
}
