//
//  SymptomGuidanceViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/8/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol MapDelegate: class {
    func linkMap(address: String)
}

class SymptomGuidanceViewController: ViewController {

    // MARK: - Properties
    fileprivate lazy var centerTableView = makeCenterTableView()
    fileprivate lazy var reportOtherButton = makeReportOtherButton()
    fileprivate lazy var doneButton = RightIconButton(
        title: R.string.localizable.done().localizedUppercase,
        icon: R.image.doneCircleArrow())
    fileprivate lazy var groupsButton: UIView = {
        let groupView = ButtonGroupView(button1: reportOtherButton, button2: doneButton, hasGradient: false, button1SpacePercent: 0.6)
        groupView.apply(backgroundStyle: .codGrayBackground)
        return groupView
    }()

    fileprivate lazy var thisViewModel: SymptomGuidanceViewModel = {
        return viewModel as! SymptomGuidanceViewModel
    }()

    fileprivate var centers = [HealthCenter]()

    override func bindViewModel() {
        super.bindViewModel()

        centers = thisViewModel.healthCenters

        doneButton.rx.tap.bind { [weak self] in
            self?.backOrGotoMainScreen()
        }.disposed(by: disposeBag)
    }

    override func setupViews() {
        super.setupViews()

        contentView.addSubview(centerTableView)
        contentView.addSubview(groupsButton)

        centerTableView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        groupsButton.snp.makeConstraints { (make) in
            make.top.equalTo(centerTableView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SymptomGuidanceViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return centers.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return tableView.dequeueReusableCell(withClass: HeaderTableCell.self, for: indexPath)

        case 1:
            let cell = tableView.dequeueReusableCell(withClass: HealthCenterTableCell.self, for: indexPath)
            cell.setData(healthCenter: centers[indexPath.row])
            cell.mapDelegate = self
            return cell

        default:
            return UITableViewCell()
        }
    }
}

// MARK: - MapDelegate, Navigator
extension SymptomGuidanceViewController: MapDelegate {
    func linkMap(address: String) {
        guard let addressURL = URL(string: "https://www.google.com/maps?q=\(address.urlEncoded)") else { return }
        navigator.show(segue: .safariController(addressURL), sender: self, transition: .alert)
    }

    fileprivate func gotoReportBehaviorsScreen() {
        let viewModel = ReportBehaviorsViewModel()
        navigator.show(segue: .reportBehaviors(viewModel: viewModel), sender: self,
                       transition: .navigation(type: .slide(direction: .up)))
    }

    fileprivate func backOrGotoMainScreen() {
        let viewControllers = navigationController?.viewControllers ?? []
        if let target = viewControllers.first(where: { type(of: $0) == ProfileViewController.self }) {
            navigator.popToViewController(target: target, animationType: .slide(direction: .up))
            return
        }

        let viewModel = MainViewModel()
        navigator.show(segue: .main(viewModel: viewModel), sender: self,
                       transition: .replace(type: .slide(direction: .up)))
    }
}

// MARK: - Setup views
extension SymptomGuidanceViewController {
    fileprivate func makeCenterTableView() -> TableView {
        let tableView = TableView()
        tableView.register(cellWithClass: HeaderTableCell.self)
        tableView.register(cellWithClass: HealthCenterTableCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        return tableView
    }

    fileprivate func makeReportOtherButton() -> UIButton {
        let button = LeftIconButton(
            title: R.string.localizable.reportBehaviors().localizedUppercase,
            icon: R.image.plusCircle(), spacing: 15)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.numberOfLines = 0

        button.rx.tap.bind { [weak self] in
            self?.gotoReportBehaviorsScreen()
        }.disposed(by: disposeBag)

        return button
    }
}
