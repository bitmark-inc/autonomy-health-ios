//
//  YouHealthDetailsViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/5/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class YouHealthDetailsViewController: ViewController, BackNavigator {

    // MARK: - Properties
    fileprivate lazy var scrollView = makeScrollView()
    fileprivate lazy var healthTriangleView = makeHealthView()
    fileprivate lazy var backButton = makeLightBackItem()
    fileprivate lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: nil)
    }()

    fileprivate lazy var youSymptomsView = HealthDataRow(info: R.string.localizable.symptoms().localizedUppercase)
    fileprivate lazy var youBehaviorsView = HealthDataRow(info: R.string.localizable.healthyBehaviors().localizedUppercase)
    fileprivate lazy var activeCasesView = HealthDataRow(info: R.string.localizable.activeCases().localizedUppercase)
    fileprivate lazy var symptomsView = HealthDataRow(info: R.string.localizable.symptoms().localizedUppercase)
    fileprivate lazy var behaviorsView = HealthDataRow(info: R.string.localizable.healthyBehaviors().localizedUppercase)

    fileprivate lazy var thisViewModel: YouHealthDetailsViewModel = {
        return viewModel as! YouHealthDetailsViewModel
    }()

    override func setupViews() {
        super.setupViews()

        healthTriangleView.updateLayout(score: 28, animate: false)

        let paddingContentView = makePaddingContentView()

        scrollView.addSubview(paddingContentView)
        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
        }

        contentView.addSubview(scrollView)
        contentView.addSubview(groupsButton)

        scrollView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(groupsButton.snp.top).offset(-5)
        }

        groupsButton.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    fileprivate func makePaddingContentView() -> UIView {
        return LinearView(items: [
            (healthTriangleView, 0),
            (HeaderView(header: R.string.localizable.you().localizedUppercase, lineWidth: Constant.lineHealthDataWidth), 45),
            (youSymptomsView, 30),
            (makeSeparateLine(), 14),
            (youBehaviorsView, 15),
            (HeaderView(header: R.string.localizable.neighborhood().localizedUppercase, lineWidth: Constant.lineHealthDataWidth), 38),
            (activeCasesView, 30),
            (makeSeparateLine(), 14),
            (symptomsView, 15),
            (makeSeparateLine(), 14),
            (behaviorsView, 15)
        ], bottomConstraint: true)
    }
}

// MARK: - Setup views
extension YouHealthDetailsViewController {
    fileprivate func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.contentInset = OurTheme.paddingInset
        return scrollView
    }

    fileprivate func makeHealthView() -> HealthScoreTriangle {
        return HealthScoreTriangle(score: nil)
    }

    fileprivate func makeSeparateLine() -> UIView {
        return SeparateLine(height: 1, themeStyle: .mineShaftBackground)
    }
}
