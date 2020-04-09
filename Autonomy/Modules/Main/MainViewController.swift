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
    lazy var locationLabel = makeLocationLabel()
    lazy var locationInfoView = makeLocationInfoView()
    lazy var mainCollectionView = makeMainCollectionView()
    lazy var navButtons = makeNavButtons()

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

    override func setupViews() {
        super.setupViews()

        contentView.addSubview(mainCollectionView)
        contentView.addSubview(locationInfoView)

        mainCollectionView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
                .inset(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        }

        locationInfoView.snp.makeConstraints { (make) in
            make.top.equalTo(mainCollectionView.snp.bottom).offset(10)
            make.leading.trailing.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
        }
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withClass: HealthScoreCollectionCell.self, for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? HealthScoreCollectionCell else { return }
        cell.setData()
    }
}

// MARK: - Navigator
extension MainViewController {
}

// MARK: - Setup Views
extension MainViewController {
    fileprivate func makeLocationLabel() -> Label {
        let label = Label()
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = false
        label.apply(font: R.font.atlasGroteskLight(size: 16),
                    themeStyle: .silverChaliceColor, lineHeight: 1.2)
        return label
    }

    fileprivate func makeNavButtons() -> UIView {
        let vectorNavButton = makeVectorNavButton()
        let searchButton = makeSearchButton()

        return UIStackView(arrangedSubviews: [vectorNavButton, searchButton], axis: .horizontal, spacing: 8, alignment: .fill)
    }

    fileprivate func makeVectorNavButton() -> UIButton {
        let currentNavButton = UIButton()
        currentNavButton.setImage(R.image.vector(), for: .disabled)
        currentNavButton.setImage(R.image.unselected_vector(), for: .normal)
        return currentNavButton
    }

    fileprivate func makeSearchButton() -> UIButton {
        let searchButton = UIButton()
        searchButton.setImage(R.image.search(), for: .normal)
        return searchButton
    }

    fileprivate func makeLocationInfoView() -> UIView {
        let view = UIView()
        view.addSubview(locationLabel)
        view.addSubview(navButtons)

        locationLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.7)
            make.top.centerX.equalToSuperview()
        }

        navButtons.snp.makeConstraints { (make) in
            make.top.equalTo(locationLabel.snp.bottom).offset(13)
            make.centerX.bottom.equalToSuperview()
        }

        return view
    }

    fileprivate func makeMainCollectionView() -> UICollectionView {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: flowlayout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true

        collectionView.register(cellWithClass: HealthScoreCollectionCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false

        return collectionView
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.width - 30, height: view.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
