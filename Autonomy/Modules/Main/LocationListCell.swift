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

    var locationList = 3
    weak var locationDelegate: LocationDelegate?

    fileprivate let disposeBag = DisposeBag()

    // MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    fileprivate func setupViews() {
        contentView.addSubview(locationTableView)
        locationTableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        addGestureRecognizer(swipeGesture)
    }

    @objc func handleSwipe() {
        locationDelegate?.gotoLastPOICell()
    }

    func setData() {
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
        case 0: return locationList
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
            cell.setData()
            cell.separatorInset = UIEdgeInsets.zero
            cell.rightButtons = [
            MGSwipeButton(title: "", icon: R.image.deleteLocationCell()!, backgroundColor: .clear),
            MGSwipeButton(title: "", icon: R.image.editLocationCell()!, backgroundColor: .clear)]
            cell.rightSwipeSettings.transition = .rotate3D
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withClass: AddLocationCell.self, for: indexPath)
            cell.separatorInset = UIEdgeInsets.zero
            cell.addGestureRecognizer(makeAddLocationTapGestureRecognizer())
            return cell

        default:
            return UITableViewCell()
        }
    }
}

// MARK: - UITableViewDragDelegate, UITableViewDropDelegate
extension LocationListCell: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print(sourceIndexPath)
        print(destinationIndexPath)
    }

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
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
        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = SeparateLine(height: 1)
        themeService.rx
            .bind({ $0.lightTextColor }, to: tableView.rx.separatorColor)
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
