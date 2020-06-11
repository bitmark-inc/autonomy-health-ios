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

    weak var panModalVC: ProgressPanViewController?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        importantTagViews.rearrangeViews()
    }

    override func bindViewModel() {
        super.bindViewModel()

        thisViewModel.importantResourcesRelay
            .filterNil()
            .subscribe(onNext: { [weak self] (resources) in
                self?.rebuildResourcesListView(resources: resources)

            }, onError: { [weak self] (error) in
                guard let self = self, !self.handleIfGeneralError(error: error) else { return }
                Global.log.error(error)
                self.showErrorAlertWithSupport(message: R.string.error.system())
            })
            .disposed(by: disposeBag)

        thisViewModel.addResourcesResultSubject
            .subscribe(onNext: { [weak self] (event) in
                loadingState.onNext(.hide)
                self?.panModalVC?.dismiss(animated: true, completion: { [weak self] in
                    guard let self = self else { return }
                    switch event {
                    case .next:
                        self.backResourceRatingsScreen()
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

        submitButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            let selectedResources = self.getSelectedResources()
            self.thisViewModel.add(resources: selectedResources)
            self.showProgressPanModal()
        }.disposed(by: disposeBag)
    }

    fileprivate func getSelectedResources() -> [Resource] {
        let tagViews = importantTagViews.tagViews
        return tagViews.filter { $0.isSelected }
                       .map { Resource(id: $0.id, name: $0.title) }
    }

    fileprivate func rebuildResourcesListView(resources: [Resource]) {
        importantTagViews.reset()

        for resource in resources {
            let tagView = importantTagViews.addTag((resource.id, resource.name.lowercased()))
            tagView.isSelectedRelay
                .subscribe(onNext: { [weak self] (_) in
                    self?.checkSelectedState()
                })
                .disposed(by: disposeBag)
        }
        importantTagViews.rearrangeViews()
    }

    fileprivate func showProgressPanModal() {
        let viewController = ProgressPanViewController()
        viewController.headerScreen.header = R.string.localizable.submitting().localizedUppercase
        viewController.titleLabel.setText(R.string.phrase.resourcesAddSubmitting())
        presentPanModal(viewController)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewController.indeterminateProgressBar.startAnimating()
        }

        panModalVC = viewController
    }

    fileprivate func checkSelectedState() {
        let hasSelected = importantTagViews.tagViews.contains(where: { $0.isSelected })
        submitButton.isEnabled = hasSelected
    }

    override func setupViews() {
        super.setupViews()

        let paddingContentView = LinearView(
            items: [
                (headerScreen, 0),
                (titleScreen, 0),
                (SeparateLine(height: 1), 3),
                (makeTitleLabel(text: R.string.phrase.resourcesSuggestMessage()), 23),
                (importantTagViews, 15)
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
        viewModel.newResourceSubject
            .subscribe(onNext: { [weak self] (resource) in
                guard let self = self else { return }
                self.selectIfExistingOrAdd(with: resource)
            })
            .disposed(by: disposeBag)

        navigator.show(segue: .searchResource(viewModel: viewModel),
                       sender: self,
                       transition: .customModal(type: .slide(direction: .up)))
    }

    fileprivate func selectIfExistingOrAdd(with resource: Resource) {
        for tagView in importantTagViews.tagViews {
            if tagView.id.isNotEmpty && tagView.id == resource.id {
                tagView.isSelected = true
                return
            }
        }

        let newTagView = importantTagViews.addTag((id: resource.id, value: resource.name.lowercased()))
        newTagView.isSelected = true
        submitButton.isEnabled = true
        importantTagViews.rearrangeViews()

        newTagView.isSelectedRelay
            .subscribe(onNext: { [weak self] (_) in
                self?.checkSelectedState()
            })
            .disposed(by: disposeBag)
    }

    fileprivate func backResourceRatingsScreen() {
        navigator.pop(sender: self)
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
