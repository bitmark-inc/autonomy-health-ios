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
    lazy var healthScoreTriangle = makeHealthScoreTriangle()
    lazy var locationLabel = makeLocationLabel()
    lazy var feedsTableView = makeFeedsTableView()

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

    override func setupViews() {
        super.setupViews()
        let healthScoreView = makeHealthScoreView()
        contentView.addSubview(healthScoreView)
        contentView.addSubview(locationLabel)
        contentView.addSubview(feedsTableView)

        healthScoreView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-100)
        }

        locationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(healthScoreTriangle.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }

        feedsTableView.snp.makeConstraints { (make) in
            make.top.equalTo(locationLabel.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - SkeletonTableViewDataSource
extension MainViewController: SkeletonTableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "FeedTableCell"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: FeedTableCell.self, for: indexPath)
        return cell
    }
}

extension MainViewController {
    fileprivate func makeHealthScoreTriangle() -> ImageView {
        return ImageView(image: R.image.triangle_074())
    }

    fileprivate func makeHealthScoreView() -> UIView {
        let emptyHealthScoreTriangle = ImageView(image: R.image.emptyPolygon())

        let view = UIView()
        view.addSubview(emptyHealthScoreTriangle)
        view.addSubview(healthScoreTriangle)

        emptyHealthScoreTriangle.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        healthScoreTriangle.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        return view
    }

    fileprivate func makeLocationLabel() -> Label {
        let label = Label()
        label.apply(font: R.font.atlasGroteskLight(size: 18),
                    themeStyle: .silverChaliceColor)
        return label
    }

    fileprivate func makeFeedsTableView() -> TableView {
        let tableView = TableView()
        tableView.register(cellWithClass: FeedTableCell.self)
        tableView.dataSource = self
        tableView.isSkeletonable = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 53.0
        tableView.backgroundColor = UIColor(hexString: "#2B2B2B")
        return tableView
    }
}
