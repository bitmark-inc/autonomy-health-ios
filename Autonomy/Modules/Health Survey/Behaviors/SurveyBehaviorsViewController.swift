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
import MaterialProgressBar

class SurveyBehaviorsViewController: ViewController, BackNavigator, ReportSurveyLayout {

    // MARK: - Properties
    lazy var headerScreen: UIView = {
        HeaderView(header: R.string.localizable.behaviors().localizedUppercase)
    }()
    lazy var scrollView = makeScrollView()
    lazy var titleScreen = makeTitleScreen()
    lazy var commonTagViews = TagListView()
    lazy var sampleCommonTagView = makeSampleTagListView()
    lazy var recentTagViews = TagListView()
    lazy var sampleRecentTagViews = makeSampleTagListView()
    lazy var noneRecentLabel = makeNoneRecentLabel()

    lazy var addNewSurveyView = makeAddNewBehaviorView()
    lazy var backButton = makeLightBackItem()
    lazy var doneButton = RightIconButton(
        title: R.string.localizable.submit().localizedUppercase,
        icon: R.image.upCircleArrow()!)
    lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: doneButton, hasGradient: false)
    }()

    var surveyTitleText = R.string.phrase.surveyBehaviorsTitle()
    var commonSurveyText = R.string.phrase.surveyCommonBehaviors().localizedUppercase
    var recentSurveyText = R.string.phrase.surveyRecentBehaviors().localizedUppercase

    lazy var thisViewModel: SurveyBehaviorsViewModel = {
        return viewModel as! SurveyBehaviorsViewModel
    }()

    fileprivate var behaviorList: BehaviorList?
    weak var panModalVC: ProgressPanViewController?
    var sampleHeightConstraints = [Constraint]()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        commonTagViews.rearrangeViews()
        recentTagViews.rearrangeViews()
    }

    // MARK: - bindViewModel
    override func bindViewModel() {
        super.bindViewModel()

        thisViewModel.fetchDataResultSubject
            .subscribe(onNext: { [weak self] (event) in
                guard let self = self else { return }
                switch event {
                case .error(let error):
                    self.errorForGeneral(error: error)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        thisViewModel.behaviorListRelay
            .subscribe(onNext: { [weak self] (behaviorList) in
                guard let self = self else { return }

                if let behaviorList = behaviorList {
                    self.sampleHeightConstraints.forEach { $0.update(offset: 0) }
                    self.paddingContentView.hideSkeleton()
                    self.behaviorList = behaviorList
                    self.rebuildBehaviorsScrollView()
                } else {
                    self.paddingContentView.showAnimatedSkeleton(usingColor: Constant.skeletonColor)
                }
            })
            .disposed(by: disposeBag)

        thisViewModel.surveySubmitResultSubject
            .subscribe(onNext: { [weak self] (event) in
                loadingState.onNext(.hide)
                self?.panModalVC?.dismiss(animated: true, completion: { [weak self] in
                    guard let self = self else { return }
                    switch event {
                    case .completed:
                        self.gotoReportedScreen()
                    case .error(let error):
                        self.errorForGeneral(error: error)
                    }
                })
            })
            .disposed(by: disposeBag)

        doneButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            let selectedBehaviorKeys = self.getSelectedKeys()
            self.thisViewModel.report(with: selectedBehaviorKeys)
            self.showProgressPanModal()
        }.disposed(by: disposeBag)
    }

    fileprivate func showProgressPanModal() {
        let viewController = ProgressPanViewController()
        viewController.headerScreen.header = R.string.localizable.submitting().localizedUppercase
        viewController.titleLabel.setText(R.string.phrase.surveyBehaviorReporting())
        presentPanModal(viewController)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewController.indeterminateProgressBar.startAnimating()
        }

        panModalVC = viewController
    }

    fileprivate func rebuildBehaviorsScrollView() {
        guard let behaviorList = behaviorList else { return }

        commonTagViews.reset()

        for behavior in behaviorList.officialBehaviors {
            let tagView = commonTagViews.addTag(( behavior.id, behavior.name.lowercased()))
            if thisViewModel.lastBehaviorKeys.contains(behavior.id) {
                tagView.isSelected = true
            }

            tagView.isSelectedRelay
                .subscribe(onNext: { [weak self] (_) in
                    self?.checkSelectedState()
                })
                .disposed(by: disposeBag)
        }
        commonTagViews.rearrangeViews()

        recentTagViews.reset()

        for behavior in behaviorList.neighborhoodBehaviors {
            let tagView = recentTagViews.addTag(( behavior.id, behavior.name.lowercased()))
            if thisViewModel.lastBehaviorKeys.contains(behavior.id) {
                tagView.isSelected = true
            }
            tagView.isSelectedRelay
                .subscribe(onNext: { [weak self] (_) in
                    self?.checkSelectedState()
                })
                .disposed(by: disposeBag)
        }
        recentTagViews.rearrangeViews()
        noneRecentLabel.isHidden = behaviorList.neighborhoodBehaviors.isNotEmpty
    }

    var paddingContentView: UIView!

    // MARK: - Setup views
    override func setupViews() {
        super.setupViews()
        setupLayoutViews()
    }
}

// MARK: - Navigator
extension SurveyBehaviorsViewController {
    fileprivate func gotoReportedScreen() {
        let viewModel = ReportedBehaviorViewModel()
        navigator.show(segue: .reportedBehaviors(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoAddNewBehavior() {
        let viewModel = SearchBehaviorViewModel()

        viewModel.newBehaviorSubject
            .subscribe(onNext: { [weak self] (behavior) in
                guard let self = self else { return }
                self.selectIfExistingOrAdd(with: behavior)
            })
            .disposed(by: disposeBag)

        navigator.show(segue: .searchBehavior(viewModel: viewModel), sender: self,
                       transition: .customModal(type: .slide(direction: .up)))
    }

    fileprivate func selectIfExistingOrAdd(with behavior: Behavior) {
        for tagView in (commonTagViews.tagViews + recentTagViews.tagViews) {
            if tagView.id == behavior.id {
                tagView.isSelected = true
                return
            }
        }

        let newTagView = recentTagViews.addTag((id: behavior.id, value: behavior.name.lowercased()))
        newTagView.isSelected = true
        doneButton.isEnabled = true
        recentTagViews.rearrangeViews()
        noneRecentLabel.isHidden = true

        newTagView.isSelectedRelay
            .subscribe(onNext: { [weak self] (_) in
                self?.checkSelectedState()
            })
            .disposed(by: disposeBag)
    }

    fileprivate func makeAddNewBehaviorView() -> UIView {
        let addNewView = AddRow(title: R.string.phrase.surveyReportNewBehavior())

        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event.bind { [weak self] (_) in
            self?.gotoAddNewBehavior()
        }.disposed(by: disposeBag)

        addNewView.addGestureRecognizer(tapGesture)
        return addNewView
    }
}
