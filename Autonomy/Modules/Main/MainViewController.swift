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

protocol Location1Delegate: class {
    func updatePOI(poiID: String, alias: String)
    func deletePOI(poiID: String)
}

class MainViewController: ViewController {

    // MARK: - Properties
    fileprivate lazy var mainCollectionView = makeMainCollectionView()
    fileprivate lazy var addPlaceGuideView = makeAddPlaceGuideView()
    fileprivate lazy var addLocationBar = makeAddLocationBar()

    fileprivate var pois = [PointOfInterest]()
    fileprivate let poiLimitation = 10
    fileprivate let poiSection = 2

    fileprivate let columns: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 29.0, left: 15.0, bottom: 0.0, right: 0.0)
    fileprivate let collectionViewPadding: CGFloat = 30.0
    fileprivate var addLocationBarHeightConstraint: Constraint?


    fileprivate lazy var thisViewModel: MainViewModel = {
        return viewModel as! MainViewModel
    }()

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

    // MARK: - bindViewModel
    override func bindViewModel() {
        super.bindViewModel()

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
                self.pois = poisValue.pois

                // limit number of pois
                let reachLimit = self.pois.count >= self.poiLimitation
                self.addLocationBar.isHidden = reachLimit
                self.addLocationBarHeightConstraint?.update(offset: reachLimit ? 0 : 60)

                guard poisValue.source == .remote else {
                    return
                }

                self.mainCollectionView.reloadSections(IndexSet(integer: self.poiSection))
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
    }

    fileprivate func bindYourChangeEvent() {
        thisViewModel.yourAreaProfileRelay
            .filterNil()
            .subscribe(onNext: { [weak self] (areaProfile) in
                guard let self = self,
                    let yourHealthCell = self.mainCollectionView.cellForItem(at: IndexPath(row: 1, section: 1)) as? HealthScoreCollectionCell else {
                    return
                }
                yourHealthCell.setData(score: areaProfile.score)
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
            let headerCell = collectionView.dequeueReusableCell(withClass: HeaderSingleLabelCollectionCell.self, for: indexPath)
            headerCell.label.apply(text: Constant.appName.localizedUppercase,
                                        font: R.font.domaineSansTextLight(size: 14),
                                        themeStyle: .lightTextColor)
            return headerCell
        case (1, 0): // make blank cell
            return  collectionView.dequeueReusableCell(withClass: UICollectionViewCell.self, for: indexPath)
        case (1, 1):
            return collectionView.dequeueReusableCell(withClass: HealthScoreCollectionCell.self, for: indexPath)

        case (2, _):
            let cell = collectionView.dequeueReusableCell(withClass: HealthScoreCollectionCell.self, for: indexPath)
            cell.setData(poi: pois[indexPath.row])
            cell.delegate = self
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

// MARK: - LocationDelegate
extension MainViewController: Location1Delegate {
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
extension MainViewController {
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
}

// MARK: - Setup views
extension MainViewController {
    fileprivate func makeMainCollectionView() -> UICollectionView {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: flowlayout)
        collectionView.backgroundColor = .clear
        collectionView.register(cellWithClass: HeaderSingleLabelCollectionCell.self)
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

    fileprivate func makeAddPlaceGuideView() -> UIView {
        let label = Label()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.apply(text: R.string.phrase.locationAddGuidance(),
                    font: R.font.atlasGroteskLight(size: 18),
                    themeStyle: .silverColor, lineHeight: 1.25)

        let arrowImageView = ImageView(image: R.image.doneCircleArrow())

        let view = UIView()
        view.isHidden = true
        view.addSubview(label)
        view.addSubview(arrowImageView)

        label.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        arrowImageView.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom).offset(42)
            make.centerX.bottom.equalToSuperview()
        }

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
