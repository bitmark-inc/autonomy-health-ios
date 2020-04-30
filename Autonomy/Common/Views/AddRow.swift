//
//  AddRow.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/30/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit

class AddRow: UIView {

    // MARK: - Properties
    lazy var addNewLabel = makeAddNewLabel()

    // MARK: - Inits
    init(title: String) {
        super.init(frame: CGRect.zero)

        addNewLabel.setText(title)

        let addImageView = ImageView(image: R.image.plusCircle())

        addSubview(addImageView)
        addSubview(addNewLabel)

        addImageView.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
            make.width.height.equalTo(45)
        }

        addNewLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(addImageView.snp.trailing).offset(15)
            make.top.trailing.bottom.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddRow {
    fileprivate func makeAddNewLabel() -> Label {
        let label = Label()
        label.apply(
            font: R.font.atlasGroteskLight(size: 24),
            themeStyle: .concordColor)
        return label
    }
}
