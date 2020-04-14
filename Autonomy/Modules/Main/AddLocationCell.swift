//
//  AddLocationCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/14/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import SkeletonView

class AddLocationCell: TableViewCell {

    // MARK: - Properties
    lazy var addNewLocationLabel = makeAddNewLocationLabel()

    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentCell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 0))
        }

        let plusImage = ImageView(image: R.image.concordPlusCircle())

        contentCell.addSubview(addNewLocationLabel)
        contentCell.addSubview(plusImage)

        addNewLocationLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }

        plusImage.snp.makeConstraints { (make) in
            make.leading.equalTo(addNewLocationLabel.snp.trailing).offset(15)
            make.centerY.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
                .inset(UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddLocationCell {
    fileprivate func makeAddNewLocationLabel() -> Label {
        let label = Label()
        label.apply(
            text: R.string.localizable.addNewLocation(),
            font: R.font.atlasGroteskLight(size: 24),
            themeStyle: .concordTextColor)
        return label
    }
}
