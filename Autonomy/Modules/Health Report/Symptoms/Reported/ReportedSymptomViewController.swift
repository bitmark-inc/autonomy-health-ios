//
//  ReportedSymptomViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/11/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SkeletonView

class ReportedSymptomViewController: ViewController, ReportedSurveyLayout {

    // MARK: - Properties
    lazy var headerScreen: UIView = {
        HeaderView(header: R.string.localizable.reported().localizedUppercase)
    }()
    lazy var scrollView = makeScrollView()
    lazy var titleScreen = makeTitleScreen(text: R.string.phrase.symptomsReportedTitle())
    lazy var totalDataView = ColumnDataView(title: R.string.localizable.symptomsYouReportedToday().localizedUppercase, .bad)
    lazy var communityAverageDataView = ColumnDataView(title: R.string.localizable.communityAverageForToday().localizedUppercase, .bad)
    lazy var subInfoButton = makeLearnToKeepOthersSafeButton()
    lazy var reportOtherButton = makeReportOtherButton()
    lazy var doneButton = RightIconButton(
        title: R.string.localizable.done().localizedUppercase,
        icon: R.image.doneCircleArrow())
    lazy var groupsButton: UIView = {
        let groupView = ButtonGroupView(button1: reportOtherButton, button2: doneButton, hasGradient: false, button1SpacePercent: 0.6)
        groupView.apply(backgroundStyle: .codGrayBackground)
        return groupView
    }()

    let dataViewTitleText = R.string.localizable.symptoms().localizedUppercase
    let reportOtherText = R.string.localizable.reportBehaviors().localizedUppercase

    lazy var thisViewModel: ReportedSymptomViewModel = {
        return viewModel as! ReportedSymptomViewModel
    }()

    override func bindViewModel() {
        super.bindViewModel()

        reportOtherButton.rx.tap.bind { [weak self] in
            self?.gotoReportBehaviorsScreen()
        }.disposed(by: disposeBag)

        doneButton.rx.tap.bind { [weak self] in
            self?.backOrGotoMainScreen()
        }.disposed(by: disposeBag)

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

        thisViewModel.metricsRelay
            .subscribe(onNext: {  [weak self] (metrics) in
                guard let self = self else { return }
                if let metrics = metrics {
                    self.setSkeleton(show: false)
                    self.bindData(with: metrics)
                } else {
                    self.setSkeleton(show: true)
                }

            })
            .disposed(by: disposeBag)

        subInfoButton.rx.tap.bind { [weak self] in
            self?.gotoBehaviorGuidanceView()
        }.disposed(by: disposeBag)
    }

    // MARK: - Setup views
    override func setupViews() {
        super.setupViews()

        setupLayoutViews()
    }
}

// MARK: - Navigator
extension ReportedSymptomViewController {
    fileprivate func gotoReportBehaviorsScreen() {
        let viewModel = ReportBehaviorsViewModel()
        navigator.show(segue: .reportBehaviors(viewModel: viewModel), sender: self,
                       transition: .navigation(type: .slide(direction: .up)))
    }

    fileprivate func gotoBehaviorGuidanceView() {
        navigator.show(segue: .behaviorGuidance, sender: self)
    }
}

// MARK: - Setup Views
extension ReportedSymptomViewController {
    func makeLearnToKeepOthersSafeButton() -> UIButton {
        let button = RightIconButton(
            title: R.string.localizable.learnHowToKeepOthersSafe(),
            icon: R.image.nextSilverCircle30())
        button.imageView?.contentMode = .scaleAspectFit
        button.titleLabel?.font = R.font.atlasGroteskLight(size: 18)
        button.backgroundColor = .clear
        themeService.rx
            .bind({ $0.silverColor }, to: button.rx.titleColor(for: .normal))
            .disposed(by: disposeBag)

        return button
    }
}
