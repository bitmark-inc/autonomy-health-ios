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

protocol LocationDelegate: class {
    func gotoAddLocationScreen()
    func gotoLastPOICell()
}

class MainViewController: ViewController {

    // MARK: - Properties
    lazy var locationLabel = makeLocationLabel()
    lazy var locationInfoView = makeLocationInfoView()
    lazy var mainCollectionView = makeMainCollectionView()
    lazy var pageControl = makePageControl()
    lazy var currentLocationButton = makeVectorNavButton()
    lazy var locationButton = makeLocationButton()
    lazy var navButtons = makeNavButtons()

    lazy var thisViewModel: MainViewModel = {
        return viewModel as! MainViewModel
    }()

    var lock = NSLock()
    var pois = [PointOfInterest?]()

    let sectionIndexes = (currentLocation: 0, poi: 1, poiList: 2)

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

        pageControl.numberOfPages = pois.count + 2
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

                self.locationLabel.setText(userFriendlyAddress)
            }, onError: { (error) in
                Global.log.error(error)
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
            make.top.equalTo(mainCollectionView.snp.bottom).offset(15)
            make.leading.trailing.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-OurTheme.paddingInset.bottom + 10)
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case sectionIndexes.currentLocation:    return 1
        case sectionIndexes.poi:                return pois.count
        case sectionIndexes.poiList:            return 1
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case sectionIndexes.currentLocation, sectionIndexes.poi:
            return collectionView.dequeueReusableCell(withClass: HealthScoreCollectionCell.self, for: indexPath)

        case sectionIndexes.poiList:
            let cell = collectionView.dequeueReusableCell(withClass: LocationListCell.self, for: indexPath)
            cell.locationDelegate = self
            return cell
        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard collectionView.indexPathsForVisibleItems.contains(indexPath) else { return }

        setupPageControl(with: indexPath)

        guard let cell = cell as? HealthScoreCollectionCell else { return }
        cell.setData()
    }

    fileprivate func setupPageControl(with indexPath: IndexPath) {
        let isInCurrentLocation = indexPath.section == sectionIndexes.currentLocation
        let isInPoiList = indexPath.section == sectionIndexes.poiList

        currentLocationButton.isEnabled = !isInCurrentLocation
        mainCollectionView.isScrollEnabled = !isInPoiList
        locationButton.isEnabled = !isInPoiList
        locationLabel.isHidden = isInPoiList

        switch indexPath.section {
        case sectionIndexes.currentLocation: pageControl.currentPage = 0
        case sectionIndexes.poi:             pageControl.currentPage = indexPath.row + 1
        case sectionIndexes.poiList:         pageControl.currentPage = pois.count + 1
        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let currentIndexPath = collectionView.indexPathsForVisibleItems.first else { return }
        setupPageControl(with: currentIndexPath)
    }
}

extension MainViewController: LocationDelegate {
    func gotoAddLocationScreen() {
        let viewModel = LocationSearchViewModel()
        viewModel.selectedPlaceIDSubject
            .filterNil()
            .subscribe(onNext: { [weak self] (selectedPlaceID) in
                self?.thisViewModel.addNewLocation(placeID: selectedPlaceID)
            })
            .disposed(by: disposeBag)

        navigator.show(segue: .locationSearch(viewModel: viewModel), sender: self, transition: .modal)
    }

    func gotoLastPOICell() {
        gotoPOICell(selectedIndex: pois.count, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - Navigator
extension MainViewController {
    fileprivate func gotoCurrentLocationCell(animated: Bool = false) {
        let indexPath = IndexPath(row: 0, section: sectionIndexes.currentLocation)
        mainCollectionView.scrollToItem(at: indexPath, at: .left, animated: animated)
        setupPageControl(with: indexPath)
    }

    fileprivate func gotoLocationListCell() {
        let indexPath = IndexPath(row: 0, section: sectionIndexes.poiList)
        mainCollectionView.scrollToItem(at: indexPath, at: .right, animated: false)
        setupPageControl(with: indexPath)
    }

    fileprivate func gotoPOICell(selectedIndex: Int, animated: Bool = false) {
        switch selectedIndex {
        case 0:
            gotoCurrentLocationCell(animated: animated)
        case pageControl.numberOfPages - 1:
            gotoLocationListCell()
        default:
            let indexPath = IndexPath(row: selectedIndex - 1, section: sectionIndexes.poi)
            mainCollectionView.scrollToItem(at: indexPath, at: .right, animated: animated)
            setupPageControl(with: indexPath)
        }
    }
}

// MARK: - Setup Views
extension MainViewController {
    fileprivate func makeLocationLabel() -> Label {
        let label = Label()
        label.apply(font: R.font.atlasGroteskLight(size: 16),
                    themeStyle: .silverChaliceColor)
        return label
    }

    fileprivate func makeNavButtons() -> UIView {
        themeService.rx
            .bind({ $0.background }, to: currentLocationButton.rx.backgroundColor)
            .bind({ $0.background }, to: locationButton.rx.backgroundColor)
            .disposed(by: disposeBag)

        let view = UIView()
        view.addSubview(pageControl)
        view.addSubview(currentLocationButton)
        view.addSubview(locationButton)
        pageControl.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35))
        }

        currentLocationButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(pageControl.snp.leading).offset(10)
            make.top.bottom.equalToSuperview()
        }

        locationButton.snp.makeConstraints { (make) in
            make.leading.equalTo(pageControl.snp.trailing).offset(-10)
            make.top.bottom.equalToSuperview()
        }

        return view
    }

    fileprivate func makeVectorNavButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.vector(), for: .disabled)
        button.setImage(R.image.unselected_vector(), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 29, bottom: 10, right: 3)

        button.rx.tap.bind { [weak self] in
            self?.gotoCurrentLocationCell()
        }.disposed(by: disposeBag)

        return button
    }

    fileprivate func makeLocationButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.addLocation(), for: .normal)
        button.setImage(R.image.selectedAddLocation(), for: .disabled)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 3, bottom: 10, right: 29)

        button.rx.tap.bind { [weak self] in
            self?.gotoLocationListCell()
        }.disposed(by: disposeBag)

        return button
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        pageControl.subviews.forEach {
            $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
    }

    fileprivate func makePageControl() -> UIPageControl {
        let pageControl = UIPageControl()
        pageControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let currentPage = self?.pageControl.currentPage else {
                    return
                }

                self?.gotoPOICell(selectedIndex: currentPage)
            })
            .disposed(by: disposeBag)

        return pageControl
    }

    fileprivate func makeLocationInfoView() -> UIView {
        let view = UIView()
        view.addSubview(navButtons)
        view.addSubview(locationLabel)

        locationLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.7)
            make.top.centerX.equalToSuperview()
        }

        navButtons.snp.makeConstraints { (make) in
            make.top.equalTo(locationLabel.snp.bottom).offset(-5)
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
        collectionView.register(cellWithClass: LocationListCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.delaysContentTouches = true

        return collectionView
    }
}


