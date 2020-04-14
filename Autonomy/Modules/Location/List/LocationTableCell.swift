//
//  LocationTableCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/9/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import SkeletonView
import MGSwipeTableCell

class LocationTableCell: MGSwipeTableCell {

    // MARK: - Properties
    lazy var titleLabel = makeTitleLabel()
    lazy var healthScoreLabel = makeHealthScoreLabel()
    lazy var healthScoreView = makeHealthScoreView()

    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none

        let contentCell = UIView()
        contentView.addSubview(contentCell)
        contentCell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 0))
        }

        contentCell.addSubview(titleLabel)
        contentCell.addSubview(healthScoreView)

        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
                make.leading.equalToSuperview()
            make.bottom.equalToSuperview().offset(-15)
            make.height.greaterThanOrEqualTo(60)
        }

        healthScoreView.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel.snp.trailing).offset(15)
            make.centerY.trailing.equalToSuperview()
        }
    }

    func setData() {
        titleLabel.setText("Taipei Main Station")
        healthScoreLabel.setText("94")
        healthScoreView.backgroundColor = .red
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LocationTableCell {
    fileprivate func makeTitleLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(font: R.font.atlasGroteskLight(size: 24), themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeHealthScoreView() -> UIView {
        let view = UIView()
        view.addSubview(healthScoreLabel)
        view.layer.cornerRadius = 30
        view.snp.makeConstraints { (make) in
            make.height.width.equalTo(60)
        }

        healthScoreLabel.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }
        return view
    }

    fileprivate func makeHealthScoreLabel() -> Label {
        let label = Label()
        label.apply(font: R.font.domaineSansTextLight(size: 24), themeStyle: .lightTextColor)
        return label
    }
}
