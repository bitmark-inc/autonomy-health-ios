//
//  HeaderSingleLabelCollectionCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/3/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit

class HeaderSingleLabelCollectionCell: UICollectionViewCell {

    // MARK: - Properties
    var label = Label()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
