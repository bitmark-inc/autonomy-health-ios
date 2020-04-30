//
//  BehaviorHistoryViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/29/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SkeletonView

class BehaviorHistoryViewController: ViewController, BackNavigator {

    // MARK: - Properties
    fileprivate lazy var titleSectionView = makeTitleSectionView()
    fileprivate lazy var historyTableView = makeHistoryTableView()
    fileprivate lazy var backButton = makeLightBackItem()
    fileprivate lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: nil, hasGradient: false)
    }()
    fileprivate lazy var activityIndicator = makeActivityIndicator()

    fileprivate lazy var thisViewModel: BehaviorHistoryViewModel = {
        return viewModel as! BehaviorHistoryViewModel
    }()
    fileprivate var histories = [BehaviorsHistory]()


    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

        override func bindViewModel() {
            super.bindViewModel()

            thisViewModel.behaviorHistoriesRelay
                .subscribe(onNext: { [weak self] (behaviorHistories) in
                    guard let self = self else { return }

                    if let behaviorHistories = behaviorHistories {
                        self.histories = behaviorHistories
                        self.historyTableView.hideSkeleton()
                        self.historyTableView.reloadData()

                    } else {
                        self.historyTableView.showAnimatedSkeleton(usingColor: Constant.skeletonColor)
                    }
                })
                .disposed(by: disposeBag)

            thisViewModel.loadingStateRelay
                .subscribe(onNext: { [weak self] (loadState) in
                    guard let self = self else { return }
                    loadState == .loading ?
                        self.activityIndicator.startAnimating() :
                        self.activityIndicator.stopAnimating()
                })
                .disposed(by: disposeBag)
        }

        override func setupViews() {
            super.setupViews()

            contentView.addSubview(titleSectionView)
            contentView.addSubview(historyTableView)
            contentView.addSubview(groupsButton)

            titleSectionView.snp.makeConstraints { (make) in
                make.top.leading.trailing.equalToSuperview()
                    .inset(OurTheme.profilePaddingInset)
            }

            historyTableView.snp.makeConstraints { (make) in
                make.top.equalTo(titleSectionView.snp.bottom).offset(45)
                make.leading.trailing.equalToSuperview()
            }

            groupsButton.snp.makeConstraints { (make) in
                make.top.equalTo(historyTableView.snp.bottom).offset(3)
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
    }

    // MARK: - UITableViewDataSource, UITableViewDelegate
    extension BehaviorHistoryViewController: SkeletonTableViewDataSource, UITableViewDelegate {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return histories.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withClass: SurveyHistoryTableCell.self)
            cell.separatorInset = .zero
            let history = histories[indexPath.row]
            cell.setData(history: history)
            return cell
        }

        func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
            return "SurveyHistoryTableCell"
        }

        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            guard !thisViewModel.endRecord, let lastIndexPath = tableView.indexPathForLastRow
                else {
                    return
            }

            if indexPath.row == lastIndexPath.row {
                thisViewModel.fetchHistories(before: histories.last?.timestamp)
            }
        }
    }

    // MARK: - Setup Views
    extension BehaviorHistoryViewController {
        fileprivate func makeTitleSectionView() -> UIView {
            let titleScreenLabel = makeTitleScreenLabel()

            let view = UIView()
            view.addSubview(titleScreenLabel)
            view.addSubview(activityIndicator)

            titleScreenLabel.snp.makeConstraints { (make) in
                make.top.leading.bottom.equalToSuperview()
            }

            activityIndicator.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalTo(titleScreenLabel.snp.trailing).offset(15)
                make.trailing.lessThanOrEqualToSuperview()
            }

            return view
        }

        fileprivate func makeTitleScreenLabel() -> UILabel {
            let label = Label()
            label.apply(text: R.string.phrase.historyBehaviorTitle(),
                        font: R.font.atlasGroteskLight(size: 24),
                        themeStyle: .lightTextColor)
            return label
        }


        fileprivate func makeHistoryTableView() -> TableView {
            let tableView = TableView()
            tableView.dataSource = self
            tableView.delegate = self
            tableView.isSkeletonable = true
            tableView.register(cellWithClass: SurveyHistoryTableCell.self)
            tableView.estimatedRowHeight = 75.0
            tableView.allowsSelection = false
            return tableView
        }

        fileprivate func makeActivityIndicator() -> UIActivityIndicatorView {
            let indicator = UIActivityIndicatorView()
            indicator.style = .white
            return indicator
        }
}
