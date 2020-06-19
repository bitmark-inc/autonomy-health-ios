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
        let groupView = ButtonGroupView(button1: backButton, button2: nil, hasGradient: false)
        groupView.apply(backgroundStyle: .codGrayBackground)
        return groupView
    }()

    fileprivate lazy var nameLabel = makeNameLabel()
    fileprivate lazy var addressLabel = makeAddressLabel()
    fileprivate lazy var emptyResourceView = makeEmptyResourceView()
    fileprivate lazy var presentResourceView = makePresentResourceView()
    fileprivate lazy var resourceListView = makeResourceListView()
    fileprivate lazy var moreResourceButton = makeMoreResourceButton()
    fileprivate lazy var ratingResourceButton = makeRatingResourceButton()

    fileprivate lazy var activeCasesView = makePOICasesView()
    fileprivate lazy var symptomsView = makePOISymptomsView()
    fileprivate lazy var behaviorsView = makePOIBehaviorsView()

    var isButtonAddResource: Bool = true
    var isFullResources: Bool = false

    fileprivate lazy var thisViewModel: PlaceHealthDetailsViewModel = {
        return viewModel as! PlaceHealthDetailsViewModel
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        thisViewModel.fetchPOIAutonomyProfile(allResources: isFullResources)
    }

    override func bindViewModel() {
        super.bindViewModel()

        thisViewModel.poiAutonomyProfileRelay
            .filterNil()
            .subscribe(onNext: { [weak self] in
                self?.setData(autonomyProfile: $0)
            })
            .disposed(by: disposeBag)

        ratingResourceButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.isButtonAddResource ?
                self.gotoAddResourceScreen() :
                self.gotoResourceRatingScreen()
        }.disposed(by: disposeBag)

        moreResourceButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.isFullResources = true
            self.thisViewModel.fetchPOIAutonomyProfile(allResources: true)
        }.disposed(by: disposeBag)
    }

    fileprivate func setData(autonomyProfile: PlaceAutonomyProfile) {
        nameLabel.setText(autonomyProfile.alias.localizedUppercase)
        healthTriangleView.updateLayout(score: autonomyProfile.autonomyScore, animate: false)
        healthTriangleView.set(delta: autonomyProfile.autonomyScoreDelta)

        addressLabel.setText(autonomyProfile.address)

        let neighbor = autonomyProfile.neighbor
        activeCasesView.setData(number: neighbor.activeCase, delta: neighbor.activeCaseDelta, thingType: .bad)
        symptomsView.setData(number: neighbor.symptom, delta: neighbor.symptomDelta, thingType: .bad)
        behaviorsView.setData(number: neighbor.behavior, delta: neighbor.behaviorDelta, thingType: .good)

        moreResourceButton.isHidden = !autonomyProfile.hasMoreResources

        if autonomyProfile.resourceReportItems.count == 0 {
            ratingResourceButton.setTitle(R.string.localizable.addResource().localizedUppercase, for: .normal)
            presentResourceView.isHidden = true
            emptyResourceView.isHidden = false
            moreResourceButton.isHidden = true
            isButtonAddResource = true
        } else {
            presentResourceView.isHidden = false
            emptyResourceView.isHidden = true
            isButtonAddResource = false

            if autonomyProfile.rating {
                ratingResourceButton.setTitle(
                    R.string.localizable.viewYourRating().localizedUppercase,
                    for: .normal)
            } else {
                ratingResourceButton.setTitle(
                    R.string.localizable.addRating().localizedUppercase,
                    for: .normal)
            }

            rebuildResourceListStackView(resourceReportItems: autonomyProfile.resourceReportItems)
        }
    }

    fileprivate func rebuildResourceListStackView(resourceReportItems: [ResourceReportItem]) {
        resourceListView.removeArrangedSubviews()
        resourceListView.removeSubviews()

        let newArrangedSubviews = resourceReportItems.map { (resourceReportItem) -> UIView in
            let healthDataRow = HealthDataRow(info: resourceReportItem.resource.name.localizedUppercase, hasDot: true)
            healthDataRow.setData(resourceReportItem: resourceReportItem)

            return LinearView(
                items: [(healthDataRow, 0), (SeparateLine(height: 1, themeStyle: .mineShaftBackground), 14)],
                bottomConstraint: true)
        }

        resourceListView.addArrangedSubviews(newArrangedSubviews)
    }

    override func setupViews() {
        super.setupViews()

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

        // hide presentResourceView at first
        presentResourceView.isHidden = true
    }

    fileprivate func makePaddingContentView() -> UIView {
        let resourceView = makeResourceView()

        nameLabel.snp.makeConstraints { (make) in
            make.height.equalTo(18)
        }

        let view = LinearView(items: [
            (nameLabel, 0),
            (healthTriangleView, 42),
            (makeDataHeaderLabel(text: R.string.localizable.address().localizedUppercase), 30),
            (makeAddressView(), 8),
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
        guard let poiAutonomyProfile = thisViewModel.poiAutonomyProfileRelay.value else { return }
        guard let targetURL = URL(string: "https://www.google.com/maps?q=\(poiAutonomyProfile.address.urlEncoded)") else { return }
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

    fileprivate func gotoAutonomyTrendingScreen() {
        let viewModel = AutonomyTrendingViewModel(autonomyObject: .poi(poiID: thisViewModel.poiID))
        navigator.show(segue: .autonomyTrending(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoPOISymptomsTrendingScreen() {
        let viewModel = ItemTrendingViewModel(
            autonomyObject: .poi(poiID: thisViewModel.poiID),
            reportItemObject: .symptoms)
        navigator.show(segue: .dataItemTrending(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoPOIBehaviorsTrendingScreen() {
        let viewModel = ItemTrendingViewModel(
            autonomyObject: .poi(poiID: thisViewModel.poiID),
            reportItemObject: .behaviors)
        navigator.show(segue: .dataItemTrending(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoPOICasesTrendingScreen() {
        let viewModel = ItemTrendingViewModel(
            autonomyObject: .poi(poiID: thisViewModel.poiID),
            reportItemObject: .cases)
        navigator.show(segue: .dataItemTrending(viewModel: viewModel), sender: self)
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

    fileprivate func makeNameLabel() -> Label {
        let label = Label()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.apply(font: R.font.domaineSansTextLight(size: 18),
                    themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeHealthView() -> HealthScoreTriangle {
        let triangle = HealthScoreTriangle(score: nil)
        triangle.addGestureRecognizer(makeTriangleGestureRecognizer())
        return triangle
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
            items: [(makeResourceHeaderView(), 0), (resourceListView, 15)],
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
        let scoreHeaderLabel = makeDataHeaderLabel(text: R.string.localizable.score_1_5().localizedUppercase)
        let ratingsHeaderLabel = makeDataHeaderLabel(text: R.string.localizable.ratings().localizedUppercase)

        let view = UIView()
        view.addSubview(resourceHeaderLabel)
        view.addSubview(scoreHeaderLabel)
        view.addSubview(ratingsHeaderLabel)

        scoreHeaderLabel.textAlignment = .right
        ratingsHeaderLabel.textAlignment = .right

        resourceHeaderLabel.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(scoreHeaderLabel.snp.leading)
        }

        scoreHeaderLabel.snp.makeConstraints { (make) in
            make.width.equalTo(70)
            make.top.bottom.equalTo(resourceHeaderLabel)
        }

        ratingsHeaderLabel.snp.makeConstraints { (make) in
            make.width.equalTo(Size.dw(105))
            make.leading.equalTo(scoreHeaderLabel.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
        }
        return view
    }

    fileprivate func makeResourceListView() -> UIStackView {
        return UIStackView(arrangedSubviews: [], axis: .vertical, spacing: 15)
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
        button.isHidden = true
        return button
    }

    fileprivate func makeRatingResourceButton() -> UIButton {
        let button = RightIconButton(
            title: R.string.localizable.addResource().localizedUppercase,
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
        mapIconButton.setImage(R.image.crossCircleArrowIcon(), for: .normal)
        mapIconButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 29, bottom: 29, right: 0)

        mapIconButton.rx.tap.bind { [weak self] in
            self?.linkMap()
        }.disposed(by: disposeBag)

        let view = UIView()
        view.addSubview(addressLabel)
        view.addSubview(mapIconButton)

        addressLabel.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-59)
        }

        mapIconButton.snp.makeConstraints { (make) in
            make.top.trailing.equalToSuperview()
        }

        return view
    }

    fileprivate func makeAddressLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: " ", font: R.font.atlasGroteskLight(size: 18), themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeTriangleGestureRecognizer() -> UITapGestureRecognizer {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.rx.event.bind { [weak self] (_) in
            self?.gotoAutonomyTrendingScreen()
        }.disposed(by: disposeBag)
        return tapGestureRecognizer
    }

    fileprivate func makePOICasesView() -> HealthDataRow {
        let dataRow = HealthDataRow(info: R.string.localizable.activeCases().localizedUppercase)
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.rx.event.bind { [weak self] (_) in
            self?.gotoPOICasesTrendingScreen()
        }.disposed(by: disposeBag)

        dataRow.addGestureRecognizer(tapGestureRecognizer)
        return dataRow
    }

    fileprivate func makePOISymptomsView() -> HealthDataRow {
        let dataRow = HealthDataRow(info: R.string.localizable.symptoms().localizedUppercase)
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.rx.event.bind { [weak self] (_) in
            self?.gotoPOISymptomsTrendingScreen()
        }.disposed(by: disposeBag)

        dataRow.addGestureRecognizer(tapGestureRecognizer)
        return dataRow
    }

    fileprivate func makePOIBehaviorsView() -> HealthDataRow {
        let dataRow = HealthDataRow(info: R.string.localizable.healthyBehaviors().localizedUppercase)
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.rx.event.bind { [weak self] (_) in
            self?.gotoPOIBehaviorsTrendingScreen()
        }.disposed(by: disposeBag)

        dataRow.addGestureRecognizer(tapGestureRecognizer)
        return dataRow
    }
}
