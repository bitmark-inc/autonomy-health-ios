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
        HeaderView(header: R.string.localizable.ratings().localizedUppercase, lineWidth: Size.dw(105))
    }()
    fileprivate lazy var scrollView = makeScrollView()
    fileprivate lazy var titleScreen = makeTitleScreen()
    fileprivate lazy var resourceRatingListView = makeResourceRatingListView()
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

    weak var panModalVC: ProgressPanViewController?

    override func bindViewModel() {
        super.bindViewModel()

        thisViewModel.resourceRatingsRelay
            .filterNil()
            .subscribe(onNext: { [weak self] (resourceRatings) in
                self?.buildResourceRatingListView(resourceRatings: resourceRatings)
            })
            .disposed(by: disposeBag)

        submitButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            let updatedRatings = self.getUpdatedRatings()
            self.showProgressPanModal()
            self.thisViewModel.submitRatings(ratings: updatedRatings)
        }.disposed(by: disposeBag)

        thisViewModel.submitRatingsResultSubject
            .subscribe(onNext: { [weak self] (event) in
                loadingState.onNext(.hide)
                self?.panModalVC?.dismiss(animated: true, completion: { [weak self] in
                    guard let self = self else { return }
                    switch event {
                    case .completed:
                        self.backPlaceAutonomyProfileScreen()
                    case .error(let error):
                        guard !self.handleIfGeneralError(error: error) else { return }
                        Global.log.error(error)
                        self.showErrorAlertWithSupport(message: R.string.error.system())
                    }
                })
            })
            .disposed(by: disposeBag)
    }

    fileprivate func getUpdatedRatings() -> [ResourceRating] {
        guard let resourceRatingView = resourceRatingListView.arrangedSubviews as? [ResourceRatingView] else { return [] }
        return resourceRatingView.compactMap { (view) -> ResourceRating? in
            guard let thisResource = view.resource else { return nil }
            let thisRating = view.currentRating

            return ResourceRating(resource: thisResource, score: Int(thisRating.rounded()))
        }
    }

    fileprivate func showProgressPanModal() {
        let viewController = ProgressPanViewController()
        viewController.headerScreen.header = R.string.localizable.submitting().localizedUppercase
        viewController.titleLabel.setText(R.string.phrase.resourcesRatingsSubmitting())
        presentPanModal(viewController)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewController.indeterminateProgressBar.startAnimating()
        }

        panModalVC = viewController
    }

    override func setupViews() {
        super.setupViews()

        let paddingContentView = LinearView(
            items: [
                (headerScreen, 0),
                (titleScreen, 0),
                (SeparateLine(height: 1), 3)
            ],
            bottomConstraint: true)

        scrollView.addSubview(paddingContentView)
        scrollView.addSubview(resourceRatingListView)
        scrollView.addSubview(addResourceView)

        paddingContentView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(OurTheme.paddingInset)
            make.width.equalToSuperview().offset(-30)
        }

        resourceRatingListView.snp.makeConstraints { (make) in
            make.top.equalTo(paddingContentView.snp.bottom).offset(17)
            make.leading.trailing.equalToSuperview()
        }

        addResourceView.snp.makeConstraints { (make) in
            make.top.equalTo(resourceRatingListView.snp.bottom).offset(15)
            make.leading.trailing.equalTo(paddingContentView)
            make.bottom.equalToSuperview()
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

        viewModel.addResourcesResultSubject
            .subscribe(onNext: { [weak self] (event) in
                guard let self = self else { return }
                switch event {
                case .next(let resources):
                    self.addNewResourceIntoRatingListView(resources: resources)

                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        navigator.show(segue: .addResource(viewModel: viewModel), sender: self)
    }

    fileprivate func backPlaceAutonomyProfileScreen() {
        navigator.pop(sender: self)
    }
}

extension ResourceRatingViewController {
    fileprivate func addNewResourceIntoRatingListView(resources: [Resource]) {
        guard let currentResourceRatings = resourceRatingListView.arrangedSubviews as? [ResourceRatingView] else { return }

        // filter resources already in the ratings list
        let filteredResources = resources.filter { (resource) in
            !currentResourceRatings.contains(where: { $0.resource.id == resource.id })
        }

        for resource in filteredResources {
            let newView = ResourceRatingView(resource: resource)
            resourceRatingListView.addArrangedSubview(newView)
        }
    }

    fileprivate func buildResourceRatingListView(resourceRatings: [ResourceRating]) {
        resourceRatingListView.removeArrangedSubviews()
        resourceRatingListView.removeSubviews()

        let newArrangedSubviews = resourceRatings.map { (resourceRating) -> ResourceRatingView in
            let resourceRatingView = ResourceRatingView(resource: resourceRating.resource, initValue: resourceRating.score)
            if resourceRating.resource.id == thisViewModel.highlightResourceID {
                resourceRatingView.highlight()
            }
            return resourceRatingView
        }

        resourceRatingListView.addArrangedSubviews(newArrangedSubviews)
    }
}

// MARK: - Setup views
extension ResourceRatingViewController {
    fileprivate func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        var edgeInset = OurTheme.paddingInset; edgeInset.left = 0; edgeInset.right = 0
        scrollView.contentInset = edgeInset
        return scrollView
    }

    fileprivate func makeTitleScreen() -> UIView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.resourcesRatingsTitle(),
                    font: R.font.atlasGroteskLight(size: OurTheme.largeTitleFontSize),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return CenterView(contentView: label, shrink: true)
    }

    fileprivate func makeResourceRatingListView() -> UIStackView {
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
