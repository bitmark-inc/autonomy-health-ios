//
//  PlaceHealthDetailsViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/5/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PlaceHealthDetailsViewController: ViewController, BackNavigator {

    // MARK: - Properties
    fileprivate lazy var scrollView = makeScrollView()
    fileprivate lazy var healthTriangleView = makeHealthView()
    fileprivate lazy var backButton = makeLightBackItem()
    fileprivate lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: nil)
    }()

    fileprivate lazy var addressLabel = makeAddressLabel()
    fileprivate lazy var emptyResourceView = makeEmptyResourceView()
    fileprivate lazy var presentResourceView = makePresentResourceView()
    fileprivate lazy var resourceListView = makeResourceListView()
    fileprivate lazy var moreResourceButton = makeMoreResourceButton()
    fileprivate lazy var ratingResourceButton = makeRatingResourceButton()

    fileprivate lazy var activeCasesView = HealthDataRow(info: R.string.localizable.activeCases().localizedUppercase)
    fileprivate lazy var symptomsView = HealthDataRow(info: R.string.localizable.symptoms().localizedUppercase)
    fileprivate lazy var behaviorsView = HealthDataRow(info: R.string.localizable.healthyBehaviors().localizedUppercase)

    fileprivate lazy var thisViewModel: PlaceHealthDetailsViewModel = {
        return viewModel as! PlaceHealthDetailsViewModel
    }()

    override func bindViewModel() {
        super.bindViewModel()

        ratingResourceButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }

            self.gotoResourceRatingScreen()

        }.disposed(by: disposeBag)
    }

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

        let resourceView = makeResourceView()

        let view = LinearView(items: [
            (healthTriangleView, 0),
            (makeDataHeaderLabel(text: R.string.localizable.address().localizedUppercase), 30),
            (makeAddressView(), 0),
            (HeaderView(header: R.string.localizable.reportCard().localizedUppercase, lineWidth: Constant.lineHealthDataWidth), 38),
            (resourceView, 15),
            (makeResourceButtonGroupView(), 17),
            (HeaderView(header: R.string.localizable.neighborhood().localizedUppercase, lineWidth: Constant.lineHealthDataWidth), 45),
            (activeCasesView, 30),
            (makeSeparateLine(), 14),
            (symptomsView, 15),
            (makeSeparateLine(), 14),
            (behaviorsView, 15)
        ], bottomConstraint: true)

        return view
    }
}

extension PlaceHealthDetailsViewController {
    fileprivate func linkMap() {
        var address = "" // TODO: put address
//        if address.isEmpty { address = thisViewModel.poi.alias }
        print(address)
        guard let targetURL = URL(string: "https://www.google.com/maps?q=\(address.urlEncoded)") else { return }
        navigator.show(segue: .safariController(targetURL), sender: self, transition: .alert)
    }

    fileprivate func gotoAddResourceScreen() {
        let viewModel = AddResourceViewModel(poiID: thisViewModel.poiID)
        navigator.show(segue: .addResource(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoResourceRatingScreen() {
        let viewModel = ResourceRatingViewModel(poiID: thisViewModel.poiID)
        navigator.show(segue: .resourceRating(viewModel: viewModel), sender: self)
    }
}

// MARK: - Setup views
extension PlaceHealthDetailsViewController {
    fileprivate func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.isUserInteractionEnabled = true
        scrollView.contentInset = OurTheme.paddingInset
        return scrollView
    }

    fileprivate func makeHealthView() -> HealthScoreTriangle {
        return HealthScoreTriangle(score: nil)
    }

    fileprivate func makeSeparateLine() -> UIView {
        return SeparateLine(height: 1, themeStyle: .mineShaftBackground)
    }

    fileprivate func makeResourceView() -> UIView {
        let view = UIView()
        view.addSubview(emptyResourceView)
        view.addSubview(presentResourceView)

        emptyResourceView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(11)
            make.leading.trailing.bottom.equalToSuperview()
        }

        presentResourceView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        return view
    }

    fileprivate func makePresentResourceView() -> UIView {
        return LinearView(
            items: [(makeResourceHeaderView(), 0), (resourceListView, 0)],
            bottomConstraint: true
        )
    }

    fileprivate func makeEmptyResourceView() -> UIView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.resourcesEmptyGuide(),
                    font: R.font.atlasGroteskLight(size: 18),
                    themeStyle: .concordColor, lineHeight: 1.2)

        let imageView = ImageView(image: R.image.downArrow())
        let separate = SeparateLine(height: 1, themeStyle: .mineShaftBackground)

        let view = UIView()
        view.addSubview(label)
        view.addSubview(imageView)
        view.addSubview(separate)

        label.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-30)
        }

        separate.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview()
        }

        return view
    }

    fileprivate func makeResourceHeaderView() -> UIView {
        let resourceHeaderLabel = makeDataHeaderLabel(text: R.string.localizable.resource().localizedUppercase)
        let scoreHeaderLabel = makeDataHeaderLabel(text: R.string.localizable.score_0_5().localizedUppercase)
        let ratingsHeaderLabel = makeDataHeaderLabel(text: R.string.localizable.ratings().localizedUppercase)

        let view = UIView()
        view.addSubview(resourceHeaderLabel)
        view.addSubview(scoreHeaderLabel)
        view.addSubview(ratingsHeaderLabel)

        scoreHeaderLabel.textAlignment = .right
        ratingsHeaderLabel.textAlignment = .right

        resourceHeaderLabel.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.58)
            make.trailing.equalTo(scoreHeaderLabel.snp.leading)
        }

        scoreHeaderLabel.snp.makeConstraints { (make) in
            make.width.equalTo(70)
            make.top.bottom.equalTo(resourceHeaderLabel)
        }

        ratingsHeaderLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(scoreHeaderLabel.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
        }
        return view
    }

    fileprivate func makeResourceListView() -> UIView {
        return UIView()
    }

    fileprivate func makeResourceButtonGroupView() -> UIView {
        let view = UIView()
        view.addSubview(moreResourceButton)
        view.addSubview(ratingResourceButton)

        moreResourceButton.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
        }

        ratingResourceButton.snp.makeConstraints { (make) in
            make.top.trailing.bottom.equalToSuperview()
        }

        return view
    }

    fileprivate func makeMoreResourceButton() -> UIButton {
        let button = LeftIconButton(
            title: R.string.localizable.more().localizedUppercase,
            icon: R.image.moreIcon(),
            spacing: 7)
        button.apply(font: R.font.atlasGroteskLight(size: 14), textStyle: .silverColor)
        return button
    }

    fileprivate func makeRatingResourceButton() -> UIButton {
        let button = RightIconButton(
            title: R.string.localizable.addRating().localizedUppercase,
            icon: R.image.addIcon(),
            spacing: 7)
        button.apply(font: R.font.atlasGroteskLight(size: 14), textStyle: .silverColor)
        return button
    }

    fileprivate func makeDataHeaderLabel(text: String) -> Label {
        let label = Label()
        label.apply(text: text,
                    font: R.font.domaineSansTextLight(size: 10), themeStyle: .silverColor)
        return label
    }

    fileprivate func makeAddressView() -> UIView {
        let mapIconButton = UIButton()
        mapIconButton.setImage(R.image.linkMap(), for: .normal)
        mapIconButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 29, bottom: 14, right: 0)

        mapIconButton.rx.tap.bind { [weak self] in
            self?.linkMap()
        }.disposed(by: disposeBag)

        let view = UIView()
        view.addSubview(addressLabel)
        view.addSubview(mapIconButton)

        addressLabel.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(mapIconButton.snp.leading).offset(-15)
        }

        mapIconButton.snp.makeConstraints { (make) in
            make.top.trailing.bottom.equalToSuperview()
        }

        return view
    }

    fileprivate func makeAddressLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(font: R.font.atlasGroteskLight(size: 18), themeStyle: .lightTextColor)
        return label
    }
}
