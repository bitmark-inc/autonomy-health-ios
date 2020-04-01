//
//  FeedTableCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/31/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import SkeletonView
import BEMCheckBox

class FeedTableCell: TableViewCell {

    // MARK: - Properties
    lazy var coloredCircle = makeColoredCircle()
    lazy var checkedCircle = makeCheckedCircle()
    lazy var atLabel = makeAtLabel()
    lazy var titleLabel = makeTitleLabel()

    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear

        let rightView = LinearView(items: [
            (atLabel, 0),
            (titleLabel, 4)
        ], bottomConstraint: true)

        let markView = makeMarkView()

        contentCell.addSubview(markView)
        contentCell.addSubview(rightView)

        markView.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
            make.width.height.equalTo(30)
        }

        rightView.snp.makeConstraints { (make) in
            make.leading.equalTo(markView.snp.trailing).offset(10)
            make.top.trailing.bottom.equalToSuperview()
        }
    }

    func setData(with helpRequest: HelpRequest) {
        atLabel.setText(helpRequest.createdAt?.formatRelative)
        titleLabel.setText(helpRequest.assistanceKind?.requestTitle)

        if helpRequest.caseState == .pending {
            checkedCircle.isHidden = true
            coloredCircle.isHidden = false
        } else {
            checkedCircle.isHidden = false
            coloredCircle.isHidden = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FeedTableCell {
    fileprivate func makeMarkView() -> UIView {
        let view = UIView()
        view.addSubview(coloredCircle)
        view.addSubview(checkedCircle)

        coloredCircle.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        checkedCircle.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        return view
    }

    fileprivate func makeColoredCircle() -> UIView {
        let coloredCircle = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        coloredCircle.cornerRadius = 15
        coloredCircle.backgroundColor = Constant.HeathColor.red
        return coloredCircle
    }

    fileprivate func makeCheckedCircle() -> BEMCheckBox {
        let checkBox = BEMCheckBox()
        checkBox.on = true
        checkBox.lineWidth = 1
        checkBox.onCheckColor = .white
        checkBox.onTintColor = Constant.HeathColor.red
        checkBox.onFillColor = Constant.HeathColor.red
        checkBox.isUserInteractionEnabled = false
        return checkBox
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
