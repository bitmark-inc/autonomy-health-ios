//
//  ReportSymptomsViewController.swift
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

class ReportSymptomsViewController: ViewController, BackNavigator, ReportSurveyLayout {

    // MARK: - Properties
    lazy var headerScreen: UIView = {
        HeaderView(header: R.string.localizable.symptoms().localizedUppercase)
    }()
    lazy var scrollView = makeScrollView()
    lazy var titleScreen = makeTitleScreen()
    lazy var commonTagViews = TagListView()
    lazy var sampleCommonTagView = makeSampleTagListView()
    lazy var recentTagViews = TagListView()
    lazy var sampleRecentTagViews = makeSampleTagListView()
    lazy var noneRecentLabel = makeNoneRecentLabel()

    lazy var addNewSurveyView = makeAddNewSymptomView()
    lazy var backButton = makeLightBackItem()
    lazy var doneButton = RightIconButton(
        title: R.string.localizable.submit().localizedUppercase,
        icon: R.image.upCircleArrow()!)
    lazy var groupsButton: UIView = {
        let groupView = ButtonGroupView(button1: backButton, button2: doneButton, hasGradient: false)
        groupView.apply(backgroundStyle: .codGrayBackground)
        return groupView
    }()

    var surveyTitleText = R.string.phrase.symptomsReportTitle()
    var commonSurveyText = R.string.phrase.symptomsReportCommon().localizedUppercase
    var recentSurveyText = R.string.phrase.symptomsReportRecent().localizedUppercase

    lazy var thisViewModel: ReportSymptomsViewModel = {
        return viewModel as! ReportSymptomsViewModel
    }()

    fileprivate var symptomList: SymptomList?
    weak var panModalVC: ProgressPanViewController?
    var sampleHeightConstraints = [Constraint]()

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
                    guard !self.handleIfGeneralError(error: error) else { return }
                    Global.log.error(error)
                    self.showErrorAlertWithSupport(message: R.string.error.system())
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        thisViewModel.symptomListRelay
            .subscribe(onNext: { [weak self] (symptomList) in
                guard let self = self else { return }

                if let symptomList = symptomList {
                    self.sampleHeightConstraints.forEach { $0.update(offset: 0) }
                    self.paddingContentView.hideSkeleton()
                    self.symptomList = symptomList
                    self.rebuildSymptomsScrollView()
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
                    case .next(let healthDetection):
                        if healthDetection.official <= 0 {
                            self.gotoReportedScreen()
                        } else {
                            self.gotoSymptomGuidanceScreen(healthCenters: healthDetection.guide)
                        }
                    case .error(let error):
                        guard !self.handleIfGeneralError(error: error) else { return }
                        Global.log.error(error)
                        self.showErrorAlertWithSupport(message: R.string.error.system())

                    default:
                        break
                    }
                })
            })
            .disposed(by: disposeBag)

        doneButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            let selectedSymptomKeys = self.getSelectedKeys()
            self.thisViewModel.report(with: selectedSymptomKeys)
            self.showProgressPanModal()
        }.disposed(by: disposeBag)
    }

    fileprivate func showProgressPanModal() {
        let viewController = ProgressPanViewController()
        viewController.headerScreen.header = R.string.localizable.submitting().localizedUppercase
        viewController.titleLabel.setText(R.string.phrase.symptomsReportSubmitting())
        presentPanModal(viewController)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewController.indeterminateProgressBar.startAnimating()
        }

        panModalVC = viewController
    }

    fileprivate func rebuildSymptomsScrollView() {
        guard let symptomList = symptomList else { return }

        commonTagViews.reset()

        for symptom in symptomList.officialSymptoms {
            let tagView = commonTagViews.addTag(( symptom.id, symptom.name.lowercased()))
            if thisViewModel.lastSymptomKeys.contains(symptom.id) {
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

        for symptom in symptomList.neighborhoodSymptoms {
            let tagView = recentTagViews.addTag(( symptom.id, symptom.name.lowercased()))
            if thisViewModel.lastSymptomKeys.contains(symptom.id) {
                tagView.isSelected = true
            }
            tagView.isSelectedRelay
                .subscribe(onNext: { [weak self] (_) in
                    self?.checkSelectedState()
                })
                .disposed(by: disposeBag)
        }
        recentTagViews.rearrangeViews()
        noneRecentLabel.isHidden = symptomList.neighborhoodSymptoms.isNotEmpty
    }

    var paddingContentView: UIView!

    // MARK: - Setup views
    override func setupViews() {
        super.setupViews()
        setupLayoutViews()
    }
}

// MARK: - Navigator
extension ReportSymptomsViewController {
    fileprivate func gotoReportedScreen() {
        let viewModel = ReportedSymptomViewModel()
        navigator.show(segue: .reportedSymptoms(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoSymptomGuidanceScreen(healthCenters: [HealthCenter]) {
        let viewModel = SymptomGuidanceViewModel(healthCenters: healthCenters)
        navigator.show(segue: .symptomGuidance(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoAddNewSymptom() {
        let viewModel = SearchSymptomViewModel()

        viewModel.newSymptomSubject
            .subscribe(onNext: { [weak self] (symptom) in
                guard let self = self else { return }
                self.selectIfExistingOrAdd(with: symptom)
            })
            .disposed(by: disposeBag)

        navigator.show(segue: .searchSymptom(viewModel: viewModel), sender: self,
                       transition: .customModal(type: .slide(direction: .up)))
    }

    fileprivate func selectIfExistingOrAdd(with symptom: Symptom) {
        for tagView in (commonTagViews.tagViews + recentTagViews.tagViews) {
            if tagView.id == symptom.id {
                tagView.isSelected = true
                return
            }
        }

        let newTagView = recentTagViews.addTag((id: symptom.id, value: symptom.name.lowercased()))
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

    fileprivate func makeAddNewSymptomView() -> UIView {
        let addNewView = AddRow(title: R.string.phrase.symptomsReportAddNew())

        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event.bind { [weak self] (_) in
            self?.gotoAddNewSymptom()
        }.disposed(by: disposeBag)

        addNewView.addGestureRecognizer(tapGesture)
        return addNewView
    }
}
