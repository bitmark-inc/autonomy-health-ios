//
//  ResourceRatingViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/8/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class ResourceRatingViewController: ViewController, BackNavigator {

    // MARK: - Properties
    fileprivate lazy var headerScreen: UIView = {
        HeaderView(header: R.string.localizable.ratings().localizedUppercase)
    }()
    fileprivate lazy var scrollView = makeScrollView()
    fileprivate lazy var titleScreen = makeTitleScreen()
    fileprivate lazy var resouceRatingListView = makeResourceRatingListView()
    fileprivate lazy var addResourceView = makeAddResourceView()
    fileprivate lazy var backButton = makeLightBackItem()
    fileprivate lazy var submitButton = RightIconButton(title: R.string.localizable.submit().localizedUppercase,
                     icon: R.image.upCircleArrow()!)
    fileprivate lazy var groupsButton: UIView = {
        let groupView = ButtonGroupView(button1: backButton, button2: submitButton, hasGradient: false)
        groupView.apply(backgroundStyle: .codGrayBackground)
        return groupView
    }()

    fileprivate lazy var thisViewModel: ResourceRatingViewModel = {
        return viewModel as! ResourceRatingViewModel
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func bindViewModel() {
        super.bindViewModel()

        buildResourceRatingListView()
    }

    override func setupViews() {
        super.setupViews()

        let paddingContentView = LinearView(
            items: [
                (headerScreen, 0),
                (titleScreen, 0),
                (SeparateLine(height: 1), 3),
                (resouceRatingListView, 0),
                (addResourceView, 15)
            ],
            bottomConstraint: true)

        scrollView.addSubview(paddingContentView)
        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
        }

        contentView.addSubview(scrollView)
        contentView.addSubview(groupsButton)

        titleScreen.snp.makeConstraints { (make) in
            make.height.equalTo(OurTheme.largeTitleHeight)
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

// MARK: - Navigator
extension ResourceRatingViewController {
    fileprivate func gotoAddResourceScreen() {
        let viewModel = AddResourceViewModel(poiID: thisViewModel.poiID)
        navigator.show(segue: .addResource(viewModel: viewModel), sender: self)
    }
}

// MARK: - Setup views
extension ResourceRatingViewController {
    fileprivate func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.contentInset = OurTheme.paddingInset
        return scrollView
    }

    func makeTitleScreen() -> UIView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.resourcesRatingTitle(),
                    font: R.font.atlasGroteskLight(size: 24),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return CenterView(contentView: label, shrink: true)
    }

    func buildResourceRatingListView() {
        ["Plant-based food", "Wearning HAND-WASHING FACILITIES"].forEach { (resource) in
            let ratingView = ResourceRatingView(resource: resource)
            resouceRatingListView.addArrangedSubview(ratingView)
        }
    }

    func makeResourceRatingListView() -> UIStackView {
        return UIStackView(arrangedSubviews: [], axis: .vertical)
    }

    fileprivate func makeAddResourceView() -> UIView {
        let button = RightIconButton(
            title: R.string.localizable.addResource().localizedUppercase,
            icon: R.image.addIcon(),
            spacing: 15)
        button.apply(font: R.font.atlasGroteskLight(size: 14), textStyle: .silverColor)
        button.rx.tap.bind { [weak self] in
            self?.gotoAddResourceScreen()
        }.disposed(by: disposeBag)


        let view = UIView()
        view.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.top.trailing.bottom.equalToSuperview()
        }
        return view
    }
}
