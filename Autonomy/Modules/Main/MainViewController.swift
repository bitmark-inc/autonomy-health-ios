//
//  MainViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/27/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SkeletonView

class MainViewController: ViewController {

    // MARK: - Properties
    lazy var healthView = makeHealthView()
    lazy var locationLabel = makeLocationLabel()
    lazy var locationInfoView = makeLocationInfoView()
    lazy var feedsTableView = makeFeedsTableView()
    lazy var feedActivityIndicator = makeActivityIndicator()
    lazy var feedsRefreshControl = makeFeedsRefreshControl()

    lazy var thisViewModel: MainViewModel = {
        return viewModel as! MainViewModel
    }()
    var feeds = [HelpRequest]()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    /// setup onesignal notification
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .provisional || settings.authorizationStatus == .authorized else {
                return
            }

            DispatchQueue.main.async {
                NotificationPermission.registerOneSignal()
                NotificationPermission.scheduleReminderNotificationIfNeeded()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        thisViewModel.fetchHealthScore()
        thisViewModel.fetchFeeds()
    }

    // MARK: - bindViewModel
    override func bindViewModel() {
        super.bindViewModel()

        bindUserFriendlyAddress()

        // Score
        thisViewModel.healthScoreRelay
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.rebuildHealthView(score: $0)
            })
            .disposed(by: disposeBag)

        // Feeds
        thisViewModel.fetchFeedStateRelay
            .subscribe(onNext: { [weak self] (loadState) in
                guard let self = self else { return }
                loadState == .loading ?
                    self.feedActivityIndicator.startAnimating() :
                    self.feedActivityIndicator.stopAnimating()
            })
            .disposed(by: disposeBag)

        thisViewModel.feedsRelay
            .subscribe(onNext: { [weak self] (helpRequests) in
                guard let self = self else { return }
                self.feedsRefreshControl.endRefreshing()
                self.feeds = helpRequests
                self.feedsTableView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    fileprivate func bindUserFriendlyAddress() {
        Global.current.userLocationRelay
            .distinctUntilChanged { (previousLocation, updatedLocation) -> Bool in
                guard let previousLocation = previousLocation, let updatedLocation = updatedLocation else { return false }
                return previousLocation.distance(from: updatedLocation) < 50.0 // avoid to request reserve address too much; exceeds Apple's limitation.
            }
            .flatMap({ (location) -> Single<String?> in
                guard let location = location else { return Single.just(nil) }
                return LocationPermission.lookupAddress(from: location)
            })
            .subscribe(onNext: { [weak self] (userFriendlyAddress) in
                guard let self = self else { return }
                guard let userFriendlyAddress = userFriendlyAddress else {
                    self.locationInfoView.isHidden = true
                    return
                }

                self.locationInfoView.isHidden = false
                self.locationLabel.setText(userFriendlyAddress)
            }, onError: { [weak self] (error) in
                guard let self = self else { return }
                Global.log.error(error)
                self.locationInfoView.isHidden = true
            })
            .disposed(by: disposeBag)
    }

    fileprivate func rebuildHealthView(score: Int?) {
        let newHealthView = makeHealthScoreView(score: score)

        healthView.removeSubviews()
        healthView.addSubview(newHealthView)

        newHealthView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    @objc func reloadFeedsTable() {
        thisViewModel.fetchFeeds()
    }

    override func setupViews() {
        super.setupViews()

        contentView.addSubview(healthView)
        contentView.addSubview(locationInfoView)
        contentView.addSubview(feedsTableView)

        healthView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Size.dh(50))
            make.centerX.equalToSuperview()
            make.width.equalTo(312)
            make.height.equalTo(270)
        }

        locationInfoView.snp.makeConstraints { (make) in
            make.top.equalTo(healthView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(Size.dw(296))
        }

        feedsTableView.snp.makeConstraints { (make) in
            make.top.equalTo(locationLabel.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview()
        }

        locationInfoView.isHidden = true
    }
}

// MARK: - SkeletonTableViewDataSource
extension MainViewController: SkeletonTableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }

    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "FeedTableCell"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feed = feeds[indexPath.row]

        let cell = tableView.dequeueReusableCell(withClass: FeedTableCell.self, for: indexPath)
        cell.setData(with: feed)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feed = feeds[indexPath.row]

        guard let helpRequestID = feed.id else { return }
        gotoGiveHelpScreen(helpRequestID: helpRequestID)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = makeFeedHeaderView()

        let view = UIView()
        view.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }

        return view
    }
}

// MARK: - Navigator
extension MainViewController {
    fileprivate func gotoGiveHelpScreen(helpRequestID: String) {
        let viewModel = GiveHelpViewModel(helpRequestID: helpRequestID)
        navigator.show(segue: .giveHelp(viewModel: viewModel), sender: self)
    }
}

// MARK: - Setup Views
extension MainViewController {
    fileprivate func makeHealthView() -> UIView {
        let emptyTriangle = makeHealthScoreView(score: nil)

        let view = UIView()
        view.addSubview(emptyTriangle)
        emptyTriangle.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        return view
    }

    fileprivate func makeHealthScoreView(score: Int?) -> UIView {
        let healthScoreTriangle = HealthScoreTriangle(score: score)

        let appNameLabel = Label()
        appNameLabel.apply(text: Constant.appName.localizedUppercase,
                    font: R.font.domaineSansTextLight(size: 18),
                    themeStyle: .lightTextColor)

        let scoreLabel = Label()


        let view = UIView()
        view.addSubview(healthScoreTriangle)
        view.addSubview(appNameLabel)


        healthScoreTriangle.snp.makeConstraints { (make) in
            make.edges.centerX.equalToSuperview()
        }

        appNameLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(healthScoreTriangle).offset(-40)
        }

        if let score = score {
            scoreLabel.apply(
                text: "\(score)",
                font: R.font.domaineSansTextLight(size: 64),
                themeStyle: .lightTextColor)

            view.addSubview(scoreLabel)
            scoreLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(appNameLabel.snp.top).offset(10)
                make.centerX.equalToSuperview()
            }
        }

        return view
    }

    fileprivate func makeLocationLabel() -> Label {
        let label = Label()
        label.apply(font: R.font.atlasGroteskLight(size: 18),
                    themeStyle: .silverChaliceColor, lineHeight: 1.2)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }

    fileprivate func makeLocationInfoView() -> UIView {
        let vectorImageView = ImageView(image: R.image.vector())

        let view = UIView()
        view.addSubview(vectorImageView)
        view.addSubview(locationLabel)

        vectorImageView.snp.makeConstraints { (make) in
            make.top.leading.bottom.centerY.equalToSuperview()
            make.width.equalTo(15)
        }

        locationLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(vectorImageView.snp.trailing).offset(8)
            make.top.trailing.bottom.equalToSuperview()
        }

        return view
    }

    fileprivate func makeFeedHeaderView() -> UIView {
        let label = Label()
        label.apply(text: R.string.localizable.requests().localizedUppercase,
                    font: R.font.domaineSansTextLight(size: 14),
                    themeStyle: .lightTextColor)

        let view = UIView()
        view.addSubview(label)
        view.addSubview(feedActivityIndicator)

        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        feedActivityIndicator.snp.makeConstraints { (make) in
            make.leading.equalTo(label.snp.trailing).offset(10)
            make.top.bottom.equalToSuperview()
        }

        return view
    }

    fileprivate func makeFeedsTableView() -> TableView {
        let tableView = TableView()
        tableView.register(cellWithClass: FeedTableCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isSkeletonable = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 53.0
        tableView.backgroundColor = UIColor(hexString: "#2B2B2B")
        tableView.addSubview(feedsRefreshControl)
        return tableView
    }

    fileprivate func makeActivityIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView()
        indicator.style = .white
        return indicator
    }

    fileprivate func makeFeedsRefreshControl() -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadFeedsTable), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        return refreshControl
    }
}
