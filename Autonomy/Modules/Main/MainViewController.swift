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
import MediaPlayer
import RxAppState

protocol LocationDelegate: class {
    func updatePOI(poiID: String, alias: String)
    func deletePOI(poiID: String)
    func toggleEditMode(isOn: Bool)
}

protocol DashboardDelegate: class {
    func gotoProfileScreen()
    func gotoDebugScreen()
}

class MainViewController: ViewController {

    // MARK: - Properties
    fileprivate lazy var mainCollectionView = makeMainCollectionView()
    fileprivate lazy var addLocationBar = makeAddLocationBar()

    fileprivate var pois = [PointOfInterest]()
    fileprivate let poiSection = 2

    fileprivate let columns: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 29.0, left: 15.0, bottom: 0.0, right: 0.0)
    fileprivate let collectionViewPadding: CGFloat = 30.0
    fileprivate var addLocationBarHeightConstraint: Constraint?

    fileprivate lazy var thisViewModel: MainViewModel = {
        return viewModel as! MainViewModel
    }()

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

        NotificationCenter.default.addObserver (self, selector: #selector(volumeChanged(_:)),
            name: NSNotification.Name("AVSystemController_SystemVolumeDidChangeNotification"),
            object: nil)

        thisViewModel.fetchYouAutonomyProfile()
        thisViewModel.fetchPOIs()
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

        UIApplication.shared.rx.didOpenApp
            .subscribe(onNext: { [weak thisViewModel] _ in
                guard let thisViewModel = thisViewModel else { return }
                thisViewModel.fetchYouAutonomyProfile()
                thisViewModel.fetchPOIs()
            })
            .disposed(by: disposeBag)

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

        bindYourChangeEvent()
        bindPOIChangeEvents()
    }

    fileprivate func bindViewModelAfterViewAppear() {
        thisViewModel.poisRelay
            .subscribe(onNext: { [weak self] (poisValue) in
                guard let self = self else { return }
                let oldPOIs = self.pois
                self.pois = poisValue.pois

                guard poisValue.source == .remote else {
                    return
                }

                if oldPOIs.count != self.pois.count {
                    self.mainCollectionView.reloadSections(IndexSet(integer: self.poiSection))
                    return
                }

                for (index, newPOI) in self.pois.enumerated() {
                    let oldPOI = oldPOIs[index]

                    if oldPOI.score != newPOI.score {
                        self.mainCollectionView.reloadItems(at: [IndexPath(row: index, section: self.poiSection)])
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    override func setupViews() {
        super.setupViews()

        let paddingContentView = UIView()
        paddingContentView.addSubview(mainCollectionView)

        mainCollectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        contentView.addSubview(paddingContentView)
        contentView.addSubview(addLocationBar)

        paddingContentView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
                .inset(OurTheme.paddingInset)
        }

        addLocationBar.snp.makeConstraints { (make) in
            addLocationBarHeightConstraint = make.height.equalTo(60).constraint
            make.top.equalTo(paddingContentView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // shortcut to reset the onboarding or debug
        let volumeView = MPVolumeView(frame: CGRect.zero)
        volumeView.isHidden = true
        view.addSubview(volumeView)
        audioLevel = audioSession.outputVolume
    }

    fileprivate func bindYourChangeEvent() {
        thisViewModel.youAutonomyProfileRelay
            .filterNil()
            .subscribe(onNext: { [weak self] (autonomyProfile) in
                guard let self = self,
                    let yourHealthCell = self.mainCollectionView.cellForItem(at: IndexPath(row: 1, section: 1)) as? HealthScoreCollectionCell else {
                    return
                }
                yourHealthCell.setData(score: autonomyProfile.autonomyScore)
            })
            .disposed(by: disposeBag)
    }

    fileprivate func bindPOIChangeEvents() {
        thisViewModel.addLocationSubject
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                if $0 == nil {
                    guard let viewController = self.presentedViewController as? LocationSearchViewController else { return }
                    viewController.dismiss(animated: true, completion: nil)
                    return
                }

                let newIndexPath = IndexPath(row: self.pois.count - 1, section: self.poiSection)
                self.mainCollectionView.performBatchUpdates({
                    self.mainCollectionView.insertItems(at: [newIndexPath])

                }, completion: { [weak self] (_) in
                    guard let self = self else { return }

                    self.mainCollectionView.scrollToItem(at: newIndexPath, at: .bottom, animated: true)
                    if let viewController = self.presentedViewController as? LocationSearchViewController {
                        viewController.dismiss(animated: true, completion: nil)
                    }
                })
            })
            .disposed(by: disposeBag)

        thisViewModel.orderLocationIndexSubject
            .subscribe(onNext: { [weak self] (from, to) in
                guard let self = self else { return }

                self.mainCollectionView.performBatchUpdates({
                    self.mainCollectionView.deleteItems(at: [IndexPath(row: from, section: 1)])
                    self.mainCollectionView.insertItems(at: [IndexPath(row: to, section: 1)])
                })
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:                 return 1 // Header Label
        case 1:                 return 2
        case 2:                 return pois.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            let headerCell = collectionView.dequeueReusableCell(withClass: DashboardHeaderCollectionCell.self, for: indexPath)
            headerCell.delegate = self
            return headerCell
        case (1, 0): // make blank cell
            return  collectionView.dequeueReusableCell(withClass: UICollectionViewCell.self, for: indexPath)
        case (1, 1):
            let cell = collectionView.dequeueReusableCell(withClass: HealthScoreCollectionCell.self, for: indexPath)
            if let autonomyProfile = thisViewModel.youAutonomyProfileRelay.value {
                cell.setData(score: autonomyProfile.autonomyScore)
            }
            return cell

        case (2, _):
            let cell = collectionView.dequeueReusableCell(withClass: HealthScoreCollectionCell.self, for: indexPath)
            cell.setData(poi: pois[indexPath.row])
            cell.delegate = self
            return cell
        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            gotoYouHealthDetailsScreen()
        case poiSection:
            let poi = pois[indexPath.row]
            gotoPlaceHealthDetailsScreen(poiID: poi.id)
        default:
            break
        }
    }
}

// MARK: - LocationDelegate
extension MainViewController: LocationDelegate {
    func deletePOI(poiID: String) {
        guard let poiIDRow = pois.firstIndex(where: { $0.id == poiID }) else { return }
        let indexPath = IndexPath(row: poiIDRow, section: poiSection)
        pois.remove(at: poiIDRow)
        mainCollectionView.deleteItems(at: [indexPath])
        thisViewModel.deletePOI(poiID: poiID)
    }

    func updatePOI(poiID: String, alias: String) {
        thisViewModel.updatePOI(poiID: poiID, alias: alias)
    }

    func toggleEditMode(isOn: Bool) {
        mainCollectionView.delaysContentTouches = isOn
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: view.frame.width, height: Size.dh(45))
        default:
            let paddingSpace = sectionInsets.left * (columns - 1) + collectionViewPadding
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / columns

            // calculate heightForHealthCell
            let heightForHealthCell = HealthScoreTriangle.getScale(from: widthPerItem) * HealthScoreTriangle.originalSize.height + HealthScoreCollectionCell.space

            return CGSize(width: widthPerItem, height: heightForHealthCell)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.top
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 1:
            return UIEdgeInsets(top: 0, left: 0, bottom: Size.dh(40), right: 0)
        default:
            return UIEdgeInsets.zero
        }
    }
}


// MARK: - Navigation
extension MainViewController: DashboardDelegate {
    func gotoAddLocationScreen() {
        let viewModel = LocationSearchViewModel()
        navigator.show(segue: .locationSearch(viewModel: viewModel), sender: self, transition: .navigation(type: .pageIn(direction: .up)))
    }

    fileprivate func gotoYouHealthDetailsScreen() {
        let viewModel = YouHealthDetailsViewModel()
        navigator.show(segue: .youHealthDetails(viewModel: viewModel),
                       sender: self, transition: .navigation(type: .slide(direction: .up)))
    }

    fileprivate func gotoPlaceHealthDetailsScreen(poiID: String) {
        let viewModel = PlaceHealthDetailsViewModel(poiID: poiID)
        navigator.show(segue: .placeHealthDetails(viewModel: viewModel),
                       sender: self, transition: .navigation(type: .slide(direction: .up)))
    }

    func gotoProfileScreen() {
        navigator.show(segue: .profile, sender: self, transition: .navigation(type: .slide(direction: .down)))
    }

    func gotoDebugScreen() {
        let viewModel = DebugLocationViewModel(pois: pois)
        navigator.show(segue: .debugLocation(viewModel: viewModel), sender: self, transition: .customModal(type: .slide(direction: .up)))
    }

    fileprivate func gotoOnboardingScreen() {
        navigator.show(segue: .signInWall, sender: self, transition: .replace(type: .none))
    }
}

// MARK: - Setup views
extension MainViewController {
    fileprivate func makeMainCollectionView() -> UICollectionView {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: flowlayout)
        collectionView.backgroundColor = .clear
        collectionView.register(cellWithClass: DashboardHeaderCollectionCell.self)
        collectionView.register(cellWithClass: UICollectionViewCell.self)
        collectionView.register(cellWithClass: HealthScoreCollectionCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }

    fileprivate func makeAddLocationBar() -> UIView {
        let label = Label()
        label.apply(text: R.string.phrase.locationPlaceholder(),
                    font: R.font.atlasGroteskLight(size: 18),
                    themeStyle: .concordColor)

        let searchImageView = ImageView(image: R.image.search())

        let labelCover = UIView()
        labelCover.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerY.leading.equalToSuperview()
        }

        let view = UIView()
        view.addSubview(searchImageView)
        view.addSubview(labelCover)

        searchImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview().offset(-2)
        }

        labelCover.snp.makeConstraints { (make) in
            make.leading.equalTo(searchImageView.snp.trailing).offset(17)
            make.top.trailing.bottom.equalToSuperview()
        }

        themeService.rx
            .bind ({ $0.mineShaftBackground }, to: view.rx.backgroundColor)
            .disposed(by: disposeBag)

        labelCover.addGestureRecognizer(makeAddLocationTapGestureRecognizer())

        return view
    }

    fileprivate func makeAddLocationTapGestureRecognizer() -> UITapGestureRecognizer {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.rx.event.bind { [weak self] (_) in
            self?.gotoAddLocationScreen()
        }.disposed(by: disposeBag)
        return tapGestureRecognizer
    }
}
