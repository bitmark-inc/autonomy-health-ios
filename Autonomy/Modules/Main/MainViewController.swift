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
import MediaPlayer
import GoogleMaps

protocol LocationDelegate: class {
    var addLocationSubject: PublishSubject<PointOfInterest?> { get }

    func updatePOI(poiID: String, alias: String)
    func deletePOI(poiID: String)
    func orderPOI(from: Int, to: Int)

    func gotoAddLocationScreen()
    func gotoLastPOICell()
    func gotoPOI(with poiID: String?)
}

protocol ScoreSourceDelegate: class {
    var formStateRelay: BehaviorRelay<(cell: HealthScoreCollectionCell, state: BottomSlideViewState)?> { get }
    func explainData()
    func resetFormula()
}

class MainViewController: ViewController {

    // MARK: - Properties
    lazy var mainCollectionView = makeMainCollectionView()
    lazy var pageControl = makePageControl()
    lazy var currentLocationButton = makeVectorNavButton()
    lazy var locationButton = makeLocationButton()
    lazy var navButtons = makeNavButtons()
    lazy var profileButton = makeProfileButton()
    lazy var poiActivityIndicator = makeActivityIndicator()
    lazy var debugButton = makeDebugButton()

    lazy var thisViewModel: MainViewModel = {
        return viewModel as! MainViewModel
    }()

    var pois = [PointOfInterest]()
    var areaProfiles = [String: AreaProfile]()
    var currentUserLocationAddress: String?

    let sectionIndexes = (currentLocation: 0, poi: 1, poiList: 2)

    // View Source
    let formStateRelay = BehaviorRelay<(cell: HealthScoreCollectionCell, state: BottomSlideViewState)?>(value: nil)

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    /// setup onesignal notification
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Global.volumePressTrack = ""

        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard Global.current.account != nil else { return }
            guard settings.authorizationStatus == .provisional || settings.authorizationStatus == .authorized else {
                return
            }

            DispatchQueue.main.async {
                NotificationPermission.registerOneSignal()
                NotificationPermission.scheduleReminderNotificationIfNeeded()
            }
        }

        bindViewModelAfterViewAppear()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // clear badge notification
        UIApplication.shared.applicationIconBadgeNumber = 0

        NotificationCenter.default.addObserver (self, selector: #selector(volumeChanged(_:)),
            name: NSNotification.Name("AVSystemController_SystemVolumeDidChangeNotification"),
            object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeNotificationsObserver()
    }

    // Properties for temporary shortcut to reset the onboarding
    let audioSession = AVAudioSession.sharedInstance()
    var audioLevel: Float? = nil

    @objc func volumeChanged(_ notification: Notification) {
        if let volumePressTime = Global.volumePressTime,
            Date() >= volumePressTime.adding(.second, value: 5) {
            Global.volumePressTrack = ""
        }

        Global.volumePressTime = Date()
        guard let currentLevel = notification.userInfo!["AVSystemController_AudioVolumeNotificationParameter"] as? Float,
            let audioLevel = audioLevel else {
                return
        }

        if currentLevel > audioLevel || currentLevel == 1 { // press volume up
            Global.volumePressTrack.append("1")
        }
        if currentLevel < audioLevel || currentLevel == 0 { // press volume down
            Global.volumePressTrack.append("0")
        }

        self.audioLevel = currentLevel
        if Global.volumePressTrack.contains("00011") {
            Global.volumePressTrack = ""
            gotoOnboardingScreen()
        }

        if Global.volumePressTrack.contains("11000") {
            Global.volumePressTrack = ""
            Global.enableDebugRelay.accept(!Global.enableDebugRelay.value)
        }
    }

    // MARK: - bindViewModel
    override func bindViewModel() {
        super.bindViewModel()

        thisViewModel.signOutAccountResultSubject
            .subscribe(onNext: { [weak self] (event) in
                guard let self = self else { return }
                switch event {
                case .error(let error):
                    self.errorWhenSignOutAccount(error: error)
                case .completed:
                    Global.log.info("[done] signOut Account")
                    self.gotoOnboardingScreen()
                default:
                    break
                }
            }).disposed(by: disposeBag)

        thisViewModel.submitResultSubject
            .subscribe(onNext: { [weak self] (event) in
                guard let self = self else { return }
                switch event {
                case .error(let error):
                    Global.log.error(error)
                    if let viewController = self.presentedViewController as? LocationSearchViewController {
                        viewController.dismiss(animated: true, completion: nil)
                    }

                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        bindUserFriendlyAddress()
        bindPOIChangeEvents()
    }

    fileprivate func bindViewModelAfterViewAppear() {
        thisViewModel.poisRelay
            .subscribe(onNext: { [weak self] (poisValue) in
                guard let self = self else { return }
                self.pois = poisValue.pois

                guard poisValue.source == .remote else {
                    return
                }

                self.mainCollectionView.reloadSections(IndexSet(integer: 1))
                self.pageControl.numberOfPages = poisValue.pois.count + 2

                if self.pois.isNotEmpty, let navigatePoiID = self.thisViewModel.navigateToPoiID {
                    self.thisViewModel.navigateToPoiID = nil
                    self.gotoPOI(with: navigatePoiID)
                }
            })
            .disposed(by: disposeBag)
    }

    fileprivate func bindUserFriendlyAddress() {
        var previousLocation: CLLocation?

        Global.current.userLocationRelay
            .filter({ (location) -> Bool in
                guard let previousLocation = previousLocation, let location = location else { return true }
                return previousLocation.distance(from: location) >= 50.0 // avoid to request reserve address too much; exceeds Apple's limitation.
            })
            .flatMap({ (location) -> Single<String?> in
                previousLocation = location
                guard let location = location else { return Single.just(nil) }
                return LocationPermission.lookupAddress(from: location)
            })
            .subscribe(onNext: { [weak self] (userFriendlyAddress) in
                guard let self = self else { return }
                self.currentUserLocationAddress = userFriendlyAddress

                guard let cellForCurrent = self.mainCollectionView.cellForItem(at: IndexPath(row: 0, section: self.sectionIndexes.currentLocation)) as? HealthScoreCollectionCell else {
                    return
                }
                cellForCurrent.locationLabel.setText(userFriendlyAddress)
            }, onError: { (error) in
                Global.log.error(error)
            })
            .disposed(by: disposeBag)
    }

    fileprivate func bindPOIChangeEvents() {
        thisViewModel.fetchPOIStateRelay
            .subscribe(onNext: { [weak self] (loadState) in
                guard let self = self else { return }
                loadState == .loading ?
                    self.poiActivityIndicator.startAnimating() :
                    self.poiActivityIndicator.stopAnimating()
            })
            .disposed(by: disposeBag)

        thisViewModel.addLocationSubject
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                if $0 == nil {
                    guard let viewController = self.presentedViewController as? LocationSearchViewController else { return }
                    viewController.dismiss(animated: true, completion: nil)
                    return
                }

                self.mainCollectionView.performBatchUpdates({
                    self.mainCollectionView.insertItems(at: [IndexPath(row: self.pois.count - 1, section: 1)])

                }, completion: { [weak self] (_) in
                    guard let self = self else { return }

                    self.gotoLocationListCell()
                    if let viewController = self.presentedViewController as? LocationSearchViewController {
                        viewController.dismiss(animated: true, completion: nil)
                    }
                })
                self.pageControl.numberOfPages = self.pois.count + 2
            })
            .disposed(by: disposeBag)

        thisViewModel.deleteLocationIndexSubject
            .subscribe(onNext: { [weak self] (deletedIndex) in
                guard let self = self else { return }
                self.mainCollectionView.deleteItems(at: [IndexPath(row: deletedIndex, section: self.sectionIndexes.poi)])
                self.pageControl.numberOfPages -= 1
            })
            .disposed(by: disposeBag)

        thisViewModel.orderLocationIndexSubject
            .subscribe(onNext: { [weak self] (from, to) in
                guard let self = self else { return }

                self.mainCollectionView.performBatchUpdates({
                    self.mainCollectionView.deleteItems(at: [IndexPath(row: from, section: self.sectionIndexes.poi)])
                    self.mainCollectionView.insertItems(at: [IndexPath(row: to, section: self.sectionIndexes.poi)])
                })
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Error Handlers
    func errorWhenFetchingData(error: Error) {
        guard !AppError.errorByNetworkConnection(error),
            !showIfRequireUpdateVersion(with: error),
            !handleErrorIfAsAFError(error) else {
                return
        }

        Global.log.error(error)
        showErrorAlertWithSupport(message: R.string.error.system())
    }

    func errorWhenSignOutAccount(error: Error) {
        Global.log.error(error)
        showErrorAlertWithSupport(message: R.string.error.accountSignOutError())
    }

    override func setupViews() {
        super.setupViews()

        contentView.addSubview(profileButton)
        contentView.addSubview(navButtons)
        contentView.addSubview(mainCollectionView)
        contentView.addSubview(poiActivityIndicator)
        contentView.addSubview(debugButton)

        profileButton.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview()
        }

        debugButton.snp.makeConstraints { (make) in
            make.top.trailing.equalToSuperview()
                .inset(OurTheme.paddingInset)
        }

        navButtons.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
        }

        poiActivityIndicator.snp.makeConstraints { (make) in
            make.top.trailing.equalToSuperview().offset(30)
            make.width.height.equalTo(10)
        }

        mainCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(navButtons.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // temporary shortcut to reset the onboarding
        let volumeView = MPVolumeView(frame: CGRect.zero)
        volumeView.isHidden = true
        view.addSubview(volumeView)
        audioLevel = audioSession.outputVolume

        FormulaSupporter.mainCollectionView = mainCollectionView
    }
}

// MARK: - ScoreSourceDelegate
extension MainViewController: ScoreSourceDelegate {
    func resetFormula() {
        thisViewModel.resetFormula()
    }

    func explainData() {
        guard let cdcURL = URL(string: "https://www.cdc.gov.tw") else { return }
        navigator.show(segue: .safariController(cdcURL), sender: self, transition: .alert)
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
        case sectionIndexes.currentLocation:
            let cell = collectionView.dequeueReusableCell(withClass: HealthScoreCollectionCell.self, for: indexPath)
            cell.scoreSourceDelegate = self
            cell.locationLabel.setText(currentUserLocationAddress)
            cell.key = "current"
            return cell

        case sectionIndexes.poi:
            let cell = collectionView.dequeueReusableCell(withClass: HealthScoreCollectionCell.self, for: indexPath)
            cell.scoreSourceDelegate = self
            cell.key = pois[indexPath.row].id
            return cell

        case sectionIndexes.poiList:
            let cell = collectionView.dequeueReusableCell(withClass: LocationListCell.self, for: indexPath)
            cell.locationDelegate = self

            thisViewModel.poisRelay
                .filter { $0.source != .userAdjust }.map { $0.pois } // don't want to reload data when userAdjust; manually reload by action
                .subscribe(onNext: {
                    cell.setData(pois: $0)
                })
                .disposed(by: disposeBag)

            return cell
        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        setupPageControl(with: indexPath)

        handleWhenDisplayHealthCell(cell: cell, in: indexPath)
        handleWhenDisplayLocationList(cell: cell)
    }

    fileprivate func handleWhenDisplayHealthCell(cell: UICollectionViewCell, in indexPath: IndexPath) {
        guard let cell = cell as? HealthScoreCollectionCell else { return }

        var areaProfileKey: String?
        var locationName = ""

        switch indexPath.section {
        case sectionIndexes.currentLocation:
            locationName = currentUserLocationAddress ?? ""
        case sectionIndexes.poi:
            let poi = pois[indexPath.row]
            locationName = poi.alias
            areaProfileKey = poi.id
        default:
            break
        }

        let cellKey = areaProfileKey ?? "current"
        let areaProfile = areaProfiles[cellKey]
        cell.setData(areaProfile: areaProfile)
        cell.setData(locationName: locationName)
        cell.key = cellKey

        thisViewModel.fetchAreaProfile(poiID: areaProfileKey)
            .subscribe(onSuccess: { [weak self] (areaProfile) in
                guard let self = self else { return }
                cell.setData(areaProfile: areaProfile)
                self.areaProfiles[areaProfileKey ?? "current"] = areaProfile

            }, onError: { (error) in
                Global.log.error(error)
            })
            .disposed(by: disposeBag)
    }

    fileprivate func handleWhenDisplayLocationList(cell: UICollectionViewCell) {
        guard type(of: cell) == LocationListCell.self else { return }
        thisViewModel.fetchPOIs(source: .userAdjustFormula)
    }

    fileprivate func setupPageControl(with indexPath: IndexPath) {
        let isInCurrentLocation = indexPath.section == sectionIndexes.currentLocation
        let isInPoiList = indexPath.section == sectionIndexes.poiList

        currentLocationButton.isEnabled = !isInCurrentLocation
        locationButton.isEnabled = !isInPoiList

        switch indexPath.section {
        case sectionIndexes.currentLocation: pageControl.currentPage = 0
        case sectionIndexes.poi:             pageControl.currentPage = indexPath.row + 1
        case sectionIndexes.poiList:         pageControl.currentPage = pois.count + 1
        default:
            break
        }
    }
}

// MARK: - LocationDelegate
extension MainViewController: LocationDelegate {
    var addLocationSubject: PublishSubject<PointOfInterest?> {
        return thisViewModel.addLocationSubject
    }

    func updatePOI(poiID: String, alias: String) {
        thisViewModel.updatePOI(poiID: poiID, alias: alias)
    }

    func deletePOI(poiID: String) {
        thisViewModel.deletePOI(poiID: poiID)
    }

    func orderPOI(from: Int, to: Int) {
        thisViewModel.orderPOI(from: from, to: to)
    }

    func gotoAddLocationScreen() {
        let viewModel = LocationSearchViewModel()
        viewModel.selectedPlaceIDSubject
            .filterNil()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (selectedPlaceID) in
                guard let self = self else { return }
                self.thisViewModel.addNewPOI(placeID: selectedPlaceID)
            })
            .disposed(by: disposeBag)

        navigator.show(segue: .locationSearch(viewModel: viewModel), sender: self,
                       transition: .customModal(type: .slide(direction: .up)))
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

    func gotoPOI(with poiID: String?) {
        let index = pois.firstIndex(where: { $0.id == poiID }) ?? 0
        gotoPOICell(selectedIndex: index + 1)
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

    fileprivate func gotoOnboardingScreen() {
        navigator.show(segue: .signInWall, sender: self, transition: .replace(type: .none))
    }

    fileprivate func gotoProfileScreen() {
        navigator.show(segue: .profile, sender: self, transition: .navigation(type: .slide(direction: .down)))
    }

    fileprivate func gotoDebugScreen() {
        let viewModel = DebugLocationViewModel(pois: pois)
        navigator.show(segue: .debugLocation(viewModel: viewModel), sender: self, transition: .customModal(type: .slide(direction: .up)))
    }
}

// MARK: - Setup Views
extension MainViewController {
    fileprivate func makeProfileButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.profileButton(), for: .normal)

        button.rx.tap.bind { [weak self] in
            self?.gotoProfileScreen()
        }.disposed(by: disposeBag)

        return button
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

        defer {
            pageControl.subviews.forEach {
                $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
        }

        return pageControl
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

    fileprivate func makeActivityIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView()
        indicator.style = .white
        return indicator
    }

    fileprivate func makeDebugButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.gearIcon(), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 29, bottom: 29, right: 0)

        Global.enableDebugRelay
            .map { !$0 }
            .bind(to: button.rx.isHidden)
            .disposed(by: disposeBag)

        button.rx.tap.bind { [weak self] in
            self?.gotoDebugScreen()
        }.disposed(by: disposeBag)

        return button
    }
}


