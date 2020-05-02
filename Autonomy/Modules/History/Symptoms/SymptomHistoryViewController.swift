//
//  SymptomHistoryViewController.swift
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

class SymptomHistoryViewController: ViewController, BackNavigator {

    // MARK: - Properties
    fileprivate lazy var titleSectionView = makeTitleSectionView()
    fileprivate lazy var historyTableView = makeHistoryTableView()
    fileprivate lazy var backButton = makeLightBackItem()
    fileprivate lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: nil, hasGradient: false)
    }()
    fileprivate lazy var emptyView = makeEmptyView()
    fileprivate lazy var activityIndicator = makeActivityIndicator()

    fileprivate lazy var thisViewModel: SymptomHistoryViewModel = {
        return viewModel as! SymptomHistoryViewModel
    }()
    fileprivate var histories = [SymptomsHistory]() {
        didSet {
            let emptyRecords = histories.count <= 0
            emptyView.isHidden = !emptyRecords
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if histories.count <= 0 { // load new history after user report from navigation
            thisViewModel.fetchHistories()
        }
    }

    override func bindViewModel() {
        super.bindViewModel()

        thisViewModel.symptomHistoriesRelay
            .subscribe(onNext: { [weak self] (symptomHistories) in
                guard let self = self else { return }

                if let symptomHistories = symptomHistories {
                    self.histories = symptomHistories
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
        contentView.addSubview(emptyView)

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

        emptyView.snp.makeConstraints { (make) in
            make.top.equalTo(titleSectionView.snp.bottom).offset(45)
            make.leading.trailing.equalToSuperview()
                .inset(OurTheme.profilePaddingInset)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SymptomHistoryViewController: SkeletonTableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: SurveyHistoryTableCell.self)
        cell.separatorInset = .zero
        cell.hideSkeleton()
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

// MARK: - Navigator
extension SymptomHistoryViewController {
    fileprivate func gotoReportSymptomsScreen() {
        let viewModel = SurveySymptomsViewModel()
        navigator.show(segue: .surveySymptoms(viewModel: viewModel), sender: self)
    }
}

// MARK: - Setup Views
extension SymptomHistoryViewController {
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
        label.apply(text: R.string.phrase.historySymptomTitle(),
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

    fileprivate func makeEmptyView() -> UIView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.historySymptomEmptyDesc(),
                    font: R.font.atlasGroteskLight(size: 14),
                    themeStyle: .lightTextColor, lineHeight: 1.25)

        let reportButton = makeReportButton()

        let view = UIView()
        view.isHidden = true
        view.addSubview(label)
        view.addSubview(reportButton)

        label.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        reportButton.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom).offset(30)
            make.trailing.equalToSuperview().offset(15)
            make.bottom.equalToSuperview()
        }

        return view
    }

    fileprivate func makeReportButton() -> UIButton {
        let reportButton = RightIconButton(
            title: R.string.localizable.report().localizedUppercase,
            icon: R.image.nextCircleArrow(), spacing: 15)
        reportButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 7, right: 7)

        reportButton.rx.tap.bind { [weak self] in
            self?.gotoReportSymptomsScreen()
        }.disposed(by: disposeBag)

        return reportButton
    }

    fileprivate func makeActivityIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView()
        indicator.style = .white
        return indicator
    }
}
