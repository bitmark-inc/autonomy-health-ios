//
//  HeaderCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/13/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift

class HeaderCell: TableViewCell {

    // MARK: - Properties
    lazy  var headerScreen = {
        HeaderView(header: R.string.localizable.reported().localizedUppercase)
    }()
    lazy var titleLabel = makeTitleLabel()
    lazy var titleScreen = CenterView(contentView: titleLabel, shrink: true)

    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear

        let contentView = LinearView(items: [
            (headerScreen, 0),
            (titleScreen, 0)
        ], bottomConstraint: true)

        titleScreen.snp.makeConstraints { (make) in
            make.height.equalTo(OurTheme.titleHeight)
        }

        contentCell.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        contentCell.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(OurTheme.paddingOverBottomInset)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HeaderCell {
    func makeTitleLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(
            text: R.string.phrase.behaviorsGuidanceTitle(),
            font: R.font.atlasGroteskLight(size: Size.ds(36)),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return label
    }
}
