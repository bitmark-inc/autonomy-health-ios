//
//  FeedTableCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/31/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import SkeletonView

class FeedTableCell: TableViewCell {

    // MARK: - Properties
    lazy var coloredCircle = makeColoredCircle()
    lazy var atLabel = makeAtLabel()
    lazy var titleLabel = makeTitleLabel()

    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear

        contentCell.addSubview(coloredCircle)
        contentCell.addSubview(atLabel)
        contentCell.addSubview(titleLabel)

    }

    func setData(with helpRequest: HelpRequest) {
        atLabel.setText(helpRequest.createdAt?.formatRelative)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FeedTableCell {
    fileprivate func makeColoredCircle() -> UIView {
        let coloredCircle = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        coloredCircle.cornerRadius = 15
        coloredCircle.backgroundColor = Constant.HeathColor.red
        return coloredCircle
    }

    fileprivate func makeAtLabel() -> Label {
        let label = Label()
        label.apply(font: R.font.atlasGroteskLight(size: 12), themeStyle: .silverChaliceColor)
        return label
    }

    fileprivate func makeTitleLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(font: R.font.atlasGroteskLight(size: 16), themeStyle: .lightTextColor)
        return label
    }
}
