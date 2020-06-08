//
//  AddResourceViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/8/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AddResourceViewController: ViewController, BackNavigator {

    // MARK: - Properties
    fileprivate lazy var headerScreen: UIView = {
        HeaderView(header: R.string.localizable.addResource().localizedUppercase)
    }()
    fileprivate lazy var scrollView = makeScrollView()
    fileprivate lazy var titleScreen = makeTitleScreen()
    fileprivate lazy var importantTagViews = TagListView()
    fileprivate lazy var addNewResourceView = makeAddNewResourceView()
    fileprivate lazy var backButton = makeLightBackItem()
    fileprivate lazy var submitButton = RightIconButton(title: R.string.localizable.submit().localizedUppercase,
                     icon: R.image.upCircleArrow()!)
    fileprivate lazy var groupsButton: UIView = {
        let groupView = ButtonGroupView(button1: backButton, button2: submitButton, hasGradient: false)
        groupView.apply(backgroundStyle: .codGrayBackground)
        return groupView
    }()
    fileprivate lazy var thisViewModel: AddResourceViewModel = {
        return viewModel as! AddResourceViewModel
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        importantTagViews.rearrangeViews()
    }

    override func setupViews() {
        super.setupViews()

        let paddingContentView = LinearView(
            items: [
                (headerScreen, 0),
                (titleScreen, 0),
                (SeparateLine(height: 1), 3),
                (makeTitleLabel(text: R.string.phrase.resourcesSuggestMessage()), 23),
                (importantTagViews, 30)
            ],
            bottomConstraint: true)

        scrollView.addSubview(paddingContentView)
        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
        }

        contentView.addSubview(scrollView)
        contentView.addSubview(addNewResourceView)
        contentView.addSubview(groupsButton)

        titleScreen.snp.makeConstraints { (make) in
            make.height.equalTo(OurTheme.largeTitleHeight)
        }

        scrollView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        addNewResourceView.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        groupsButton.snp.makeConstraints { (make) in
            make.top.equalTo(addNewResourceView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension AddResourceViewController {
    fileprivate func gotoSearchResourceScreen() {
        let viewModel = SearchResourceViewModel(poiID: thisViewModel.poiID)
        navigator.show(segue: .searchResource(viewModel: viewModel),
                       sender: self,
                       transition: .customModal(type: .slide(direction: .up)))
    }
}

// MARK: - Setup views
extension AddResourceViewController {
    fileprivate func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.contentInset = OurTheme.paddingInset
        return scrollView
    }

    fileprivate func makeTitleScreen() -> UIView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.resourcesAddTitle(),
                    font: R.font.atlasGroteskLight(size: 24),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return CenterView(contentView: label, shrink: true)
    }

    fileprivate func makeTitleLabel(text: String) -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: text.localizedUppercase,
                    font: R.font.domaineSansTextLight(size: 14),
                    themeStyle: .silverColor)
        return label
    }

    fileprivate func makeAddNewResourceView() -> UIView {
        let addNewView = AddRow(title: R.string.phrase.resourcesSuggestAddPlaceholder())

        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event.bind { [weak self] (_) in
            self?.gotoSearchResourceScreen()
        }.disposed(by: disposeBag)

        addNewView.addGestureRecognizer(tapGesture)
        return addNewView
    }
}
