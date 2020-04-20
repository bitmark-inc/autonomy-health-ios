//
//  LocationListCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import SkeletonView
import MGSwipeTableCell

class LocationListCell: UICollectionViewCell {

    // MARK: - Properties
    lazy var locationTableView = makeLocationTableView()


    var pois = [PointOfInterest]()
    var poiLimitation = 10
    var addLocationObserver: Disposable?
    weak var locationDelegate: LocationDelegate? {
        didSet {
            observeAddLocationEvent()
        }
    }
    var didCallOvercomeSelectAllIssue: Bool = false

    fileprivate let disposeBag = DisposeBag()

    // MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    deinit {
        addLocationObserver?.dispose()
    }

    func setData(pois: [PointOfInterest]) {
        self.pois = pois
        locationTableView.reloadData { [weak self] in
            self?.toggleAddLocationMode(isOn: true)
        }
    }

    func observeAddLocationEvent() {
        addLocationObserver?.dispose()
        addLocationObserver = locationDelegate?.addLocationSubject
            .subscribe(onNext: { [weak self] (poi) in
                guard let self = self else { return }
                self.pois.append(poi)
                self.locationTableView.insertRows(at: [IndexPath(row: self.pois.count - 1, section: 0)], with: .automatic)
                self.toggleAddLocationMode(isOn: true)
            })
    }

    fileprivate func setupViews() {
        contentView.addSubview(locationTableView)
        locationTableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.leading.trailing.bottom.equalToSuperview()
        }

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        addGestureRecognizer(swipeGesture)
    }

    @objc func handleSwipe() {
        locationDelegate?.gotoLastPOICell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SkeletonTableViewDataSource, UITableViewDelegate
extension LocationListCell: SkeletonTableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return pois.count
        case 1: return 1
        default:
            return 0
        }
    }

    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "LocationTableCell"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withClass: LocationTableCell.self, for: indexPath)
            cell.separatorInset = UIEdgeInsets.zero
            let poi = pois[indexPath.row]
            cell.rightButtons = [
                makeDeleteLocationSwipeButton(poiID: poi.id),
                makeEditLocationSwipeButton(poiID: poi.id)]
            cell.locationDelegate = locationDelegate

            cell.setData(poiID: poi.id, alias: poi.alias, score: poi.displayScore)
            cell.parentLocationListCell = self

            if !didCallOvercomeSelectAllIssue && indexPath.row == 0 {
                didCallOvercomeSelectAllIssue = true
                cell.overcomeSelectAllIssue()
            }

            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withClass: AddLocationCell.self, for: indexPath)
            cell.separatorInset = UIEdgeInsets.zero
            cell.addGestureRecognizer(makeAddLocationTapGestureRecognizer())
            cell.isHidden = pois.count >= poiLimitation
            return cell

        default:
            return UITableViewCell()
        }
    }

    fileprivate func makeDeleteLocationSwipeButton(poiID: String) -> MGSwipeButton {
        return MGSwipeButton(title: "", icon: R.image.deleteLocationCell()!, backgroundColor: .clear) { [weak self] (_) -> Bool in
            guard let self = self, let indexRow = self.pois.firstIndex(where: { $0.id == poiID }) else {
                return true
            }

            self.pois.remove(at: indexRow)
            self.locationTableView.deleteRows(at: [IndexPath(row: indexRow, section: 0)], with: .fade)
            self.locationDelegate?.deletePOI(poiID: poiID)
            self.toggleAddLocationMode(isOn: true)
            return true
        }
    }

    fileprivate func makeEditLocationSwipeButton(poiID: String) -> MGSwipeButton {
        return MGSwipeButton(title: "", icon: R.image.editLocationCell()!, backgroundColor: .clear) { [weak self] (_) -> Bool in
            guard let self = self,
                let indexRow = self.pois.firstIndex(where: { $0.id == poiID }),
                let cell = self.locationTableView.cellForRow(at: IndexPath(row: indexRow, section: 0)) as? LocationTableCell
                else {
                    return true
            }

            cell.toggleEditMode(isOn: true)
            self.toggleAddLocationMode(isOn: false)
            return true
        }
    }

    func toggleAddLocationMode(isOn: Bool) {
        guard let addLocationCell = locationTableView.cellForRow(at: IndexPath(row: 0, section: 1)) else { return }

        if isOn && pois.count < poiLimitation {
            addLocationCell.isHidden = false
        } else {
            addLocationCell.isHidden = true
        }
    }

    func updatePOI(poiID: String, alias: String) {
        guard let updatedPOIIndex = pois.firstIndex(where: { $0.id == poiID }) else {
            Global.log.error("[incorrect data] can not find poiID")
            return
        }

        var updatedPOI = pois[updatedPOIIndex]
        updatedPOI.alias = alias
        pois[updatedPOIIndex] = updatedPOI
    }
}

// MARK: - UITableViewDragDelegate, UITableViewDropDelegate
extension LocationListCell: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let fromIndex = sourceIndexPath.row
        let toIndex = destinationIndexPath.row

        locationDelegate?.orderPOI(from: fromIndex, to: toIndex)
        let poi = pois[fromIndex]
        var orderedPOIs = pois
        orderedPOIs.remove(at: fromIndex); orderedPOIs.insert(poi, at: toIndex)
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    }
}

// MARK: - Setup views
extension LocationListCell {
    fileprivate func makeLocationTableView() -> TableView {
        let tableView = TableView()
        tableView.register(cellWithClass: LocationTableCell.self)
        tableView.register(cellWithClass: AddLocationCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.separatorStyle = .singleLine
        tableView.delaysContentTouches = true
        tableView.showsVerticalScrollIndicator = false
        themeService.rx
            .bind({ $0.lightTextColor }, to: tableView.rx.separatorColor)
            .bind({ $0.separateTableColor }, to: tableView.rx.separatorColor)
            .disposed(by: disposeBag)
        return tableView
    }

    fileprivate func makeAddLocationTapGestureRecognizer() -> UITapGestureRecognizer {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.rx.event.bind { [weak self] (_) in
            self?.locationDelegate?.gotoAddLocationScreen()
        }.disposed(by: disposeBag)
        return tapGestureRecognizer
    }
}
