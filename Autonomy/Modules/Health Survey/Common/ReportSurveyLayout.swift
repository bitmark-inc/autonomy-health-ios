//
//  ReportSurveyViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/13/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol ReportSurveyLayout: class {
    var disposeBag: DisposeBag { get }

    var headerScreen: UIView { get set }
    var titleScreen: UIView { get set }
    var scrollView: UIScrollView { get set }
    var commonTagViews: TagListView { get set }
    var sampleCommonTagView: UIView { get set }
    var recentTagViews: TagListView { get set }
    var sampleRecentTagViews: UIView { get set }
    var noneRecentLabel: Label { get set }
    var addNewSurveyView: UIView { get set }
    var doneButton: RightIconButton { get set }
    var groupsButton: UIView { get set }
    var sampleHeightConstraints: [Constraint] { get set }
    var paddingContentView: UIView! { get set }

    var surveyTitleText: String { get }
    var commonSurveyText: String { get }
    var recentSurveyText: String {  get }

    func checkSelectedState()
    func getSelectedKeys() -> [String]
    func gotoMainScreen()
    func errorWhenReport(error: Error)
    func errorForGeneral(error: Error)

    func setupLayoutViews()
    func makeScrollView() -> UIScrollView
}

extension ReportSurveyLayout where Self: ViewController {
    func getSelectedKeys() -> [String] {
        let tagViews = commonTagViews.tagViews + recentTagViews.tagViews
        return tagViews.filter { $0.isSelected }.compactMap { $0.id }
    }

    func checkSelectedState() {
        let tagViews = commonTagViews.tagViews + recentTagViews.tagViews
        let hasSelected = tagViews.contains(where: { $0.isSelected })
        doneButton.isEnabled = hasSelected
    }

    // MARK: - Error Handlers
    func errorWhenReport(error: Error) {
        guard !AppError.errorByNetworkConnection(error),
            !handleErrorIfAsAFError(error),
            !showIfRequireUpdateVersion(with: error) else {
                return
        }

        Global.log.error(error)
        showErrorAlertWithSupport(message: R.string.error.system())
    }

    func errorForGeneral(error: Error) {
        guard !AppError.errorByNetworkConnection(error),
            !showIfRequireUpdateVersion(with: error),
            !handleErrorIfAsAFError(error) else {
                return
        }

        Global.log.error(error)
        showErrorAlertWithSupport(message: R.string.error.system())
    }

    func gotoMainScreen() {
        let viewModel = MainViewModel()
        navigator.show(segue: .main(viewModel: viewModel), sender: self,
                       transition: .replace(type: .slide(direction: .down)))
    }
}


extension ReportSurveyLayout where Self: ViewController {
    func setupLayoutViews() {
        // *** Setup subviews ***
        paddingContentView = LinearView(
            items: [
                (headerScreen, 0),
                (titleScreen, 0),
                (SeparateLine(height: 1), 3),
                (makeTitleLabel(text: commonSurveyText), 23),
                (commonTagViews, 15),
                (sampleCommonTagView, 0),
                (makeTitleLabel(text: recentSurveyText), 30),
                (recentTagViews, 15),
                (sampleRecentTagViews, 0),
                (noneRecentLabel, 0)
            ],
            bottomConstraint: true)

        paddingContentView.isSkeletonable = true

        scrollView.addSubview(paddingContentView)
        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
        }

        contentView.addSubview(scrollView)
        contentView.addSubview(addNewSurveyView)
        contentView.addSubview(groupsButton)

        titleScreen.snp.makeConstraints { (make) in
            make.height.equalTo(OurTheme.titleHeight)
        }

        scrollView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        addNewSurveyView.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        groupsButton.snp.makeConstraints { (make) in
            make.top.equalTo(addNewSurveyView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        doneButton.isEnabled = false
    }

    func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.contentInset = OurTheme.paddingInset
        return scrollView
    }

    func makeTitleScreen() -> UIView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: surveyTitleText,
                    font: R.font.atlasGroteskLight(size: Size.ds(36)),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return CenterView(contentView: label, shrink: true)
    }

    func makeTitleLabel(text: String) -> Label {
        let label = Label()
        label.apply(text: text.localizedUppercase,
                    font: R.font.domaineSansTextLight(size: 14),
                    themeStyle: .silverColor)
        return label
    }

    func makeSampleTagListView() -> UIView {
        let view = UIView()
        view.isSkeletonable = true
        view.snp.makeConstraints { (make) in
            sampleHeightConstraints.append(make.height.equalTo(120).constraint)
        }
        return view
    }

    func makeNoneRecentLabel() -> Label {
        let label = Label()
        label.apply(text: R.string.localizable.none(),
                    font: R.font.atlasGroteskLight(size: 18), themeStyle: .concordColor)
        label.isHidden = true
        return label
    }
}
