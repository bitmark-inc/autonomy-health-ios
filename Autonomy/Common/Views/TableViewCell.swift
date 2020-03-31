//
//  TableViewCell.swift
//  OurBeat
//
//  Created by thuyentruong on 10/14/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import RxSwift
import SnapKit
import UIKit

class TableViewCell: UITableViewCell {
    var contentCell: UIView!
    let disposeBag = DisposeBag()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    // MARK: - Setup views

    func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none

        contentCell = UIView()
        contentView.addSubview(contentCell)

        contentCell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 7, left: OurTheme.horizontalPadding, bottom: 7, right: OurTheme.horizontalPadding))
        }

        isSkeletonable = true
        contentCell.isSkeletonable = true
    }
}
