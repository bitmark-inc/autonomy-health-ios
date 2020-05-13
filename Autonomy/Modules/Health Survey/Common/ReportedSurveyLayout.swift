//
//  ReportedSurveyLayout.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/13/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol ReportedSurveyLayout {
    var disposeBag: DisposeBag { get }

    var headerScreen: UIView { get set }
    var titleScreen: UIView { get set }
    var scrollView: UIScrollView { get set }
    var totalDataView: ColumnDataView { get set }
    var communityAverageDataView: ColumnDataView { get set }
    var subInfoButton: UIButton { get set }
    var reportOtherButton: UIButton { get set }
    var doneButton: RightIconButton { get set }
    var groupsButton: UIView { get set }

    var dataViewTitleText: String { get }
    var reportOtherText: String { get }

    func bindData(with metrics: SurveyMetrics)
    func errorForGeneral(error: Error)
    func gotoMainScreen()
    func setSkeleton(show: Bool)
    func setupLayoutViews()
}

// MARK: - Handlers
extension ReportedSurveyLayout where Self: ViewController {
    func bindData(with metrics: SurveyMetrics) {
        let me = metrics.me
        let community = metrics.community
        totalDataView.setData(number: me["total_today"], delta: me["delta"])
        communityAverageDataView.setData(number: community["avg_today"], delta: community["delta"])
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
}

extension ReportedSurveyLayout where Self: ViewController {
    func gotoMainScreen() {
        let viewModel = MainViewModel()
        navigator.show(segue: .main(viewModel: viewModel), sender: self,
                       transition: .replace(type: .slide(direction: .up)))
    }

    func setSkeleton(show: Bool) {
        if show {
            totalDataView.showAnimatedSkeleton(usingColor: Constant.skeletonColor)
            communityAverageDataView.showAnimatedSkeleton(usingColor: Constant.skeletonColor)
        } else {
            totalDataView.hideSkeleton()
            communityAverageDataView.hideSkeleton()
        }
    }

    func setupLayoutViews() {
        let dataColumnsView = UIView()
        dataColumnsView.addSubview(totalDataView)
        dataColumnsView.addSubview(communityAverageDataView)

        totalDataView.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5).offset(-7.5)
        }

        communityAverageDataView.snp.makeConstraints { (make) in
            make.leading.equalTo(totalDataView.snp.trailing).offset(15)
            make.top.trailing.bottom.equalToSuperview()
        }

        // *** Setup subviews ***
        let paddingContentView = LinearView(
            items: [
                (headerScreen, 0),
                (titleScreen, 0),
                (SeparateLine(height: 1), 3),
                (makeDataViewTitleLabel(), 15),
                (dataColumnsView, 30),
                (SeparateLine(height: 1), 30),
                (subInfoButton, 15)
            ],
            bottomConstraint: true)

        subInfoButton.snp.removeConstraints()
        subInfoButton.snp.makeConstraints { (make) in
            make.top.equalTo(dataColumnsView.snp.bottom).offset(45)
            make.trailing.bottom.equalToSuperview()
        }

        scrollView.addSubview(paddingContentView)
        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
        }

        contentView.addSubview(scrollView)
        contentView.addSubview(groupsButton)

        titleScreen.snp.makeConstraints { (make) in
            make.height.equalTo(OurTheme.titleHeight)
        }

        scrollView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        groupsButton.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - Setup views
extension ReportedSurveyLayout {
    func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.contentInset = OurTheme.paddingInset
        return scrollView
    }

    func makeTitleScreen(text: String) -> UIView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: text,
                    font: R.font.atlasGroteskLight(size: Size.ds(36)),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return CenterView(contentView: label, shrink: true)
    }

    func makeDataViewTitleLabel() -> Label {
        let label = Label()
        label.apply(text: dataViewTitleText,
                    font: R.font.domaineSansTextLight(size: 24),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        return label
    }

    func makeTitleLabel(text: String) -> Label {
        let label = Label()
        label.apply(text: text.localizedUppercase,
                    font: R.font.domaineSansTextLight(size: 14),
                    themeStyle: .silverColor)
        return label
    }

    func makeReportOtherButton() -> UIButton {
        let button = LeftIconButton(
            title: reportOtherText,
            icon: R.image.plusCircle(), spacing: 15)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.numberOfLines = 0
        return button
    }
}
