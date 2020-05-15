//
//  BehaviorGuidanceViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/13/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVKit

class BehaviorGuidanceViewController: ViewController, BackNavigator {

    fileprivate enum Guidance: CaseIterable {
        case handWashing
        case applyingHandSanitizer
        case wearningASurginalMask
        case coveringCoughs

        var title: String {
            switch self {
            case .handWashing: return R.string.localizable.handWashing()
            case .applyingHandSanitizer: return R.string.localizable.applyingHandSanitizer()
            case .wearningASurginalMask: return R.string.localizable.wearingASurgicalMask()
            case .coveringCoughs: return R.string.localizable.coveringCoughs()
            }
        }

        var videoID: String {
            return videoIDSet[Locale.current.languageCode ?? ""] ?? videoIDSet["en"]!
        }

        fileprivate var videoIDSet: [String: String] {
            switch self {
            case .handWashing:
                return [
                    "en": "OkMJ8NYeVUE",
                    "zh": "4_QBE_p0TqI"]
            case .applyingHandSanitizer:
                return [
                    "en": "q2hMrlnU5Xk",
                    "zh": "pBGKvGxHvjk"]
            case .wearningASurginalMask:
                return [
                    "en": "h7MOW7tODRs",
                    "zh": "p5eaGJivY4U"]
            case .coveringCoughs:
                return [
                    "en": "a3RXWMN-QgE",
                    "zh": "a3RXWMN-QgE"]
            }
        }
    }

    // MARK: - Properties
    fileprivate lazy var tableView = makeTableView()
    fileprivate lazy var backButton = makeLightBackItem()
    fileprivate lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: nil, hasGradient: false)
    }()
    fileprivate let guidanceCases = Guidance.allCases


    override func setupViews() {
        super.setupViews()

        contentView.addSubview(tableView)
        contentView.addSubview(groupsButton)

        tableView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        groupsButton.snp.makeConstraints { (make) in
            make.top.equalTo(tableView.snp.bottom).offset(3)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension BehaviorGuidanceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return guidanceCases.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withClass: HeaderCell.self, for: indexPath)
            cell.headerScreen.header = R.string.localizable.guidance().localizedUppercase
            cell.titleLabel.setText(R.string.phrase.behaviorsGuidanceTitle())
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withClass: VideoCell.self, for: indexPath)
            let guideCase = guidanceCases[indexPath.row]
            cell.setData(title: guideCase.title.localizedUppercase, videoID: guideCase.videoID)
            return cell
        }
    }
}

// MARK: - Setup views
extension BehaviorGuidanceViewController {
    fileprivate func makeTableView() -> TableView {
        let tableView = TableView()
        tableView.register(cellWithClass: HeaderCell.self)
        tableView.register(cellWithClass: VideoCell.self)
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        return tableView
    }
}
