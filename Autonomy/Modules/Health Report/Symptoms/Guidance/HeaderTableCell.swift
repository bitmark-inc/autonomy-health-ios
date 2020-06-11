//
//  HeaderTableCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/9/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift

class HeaderTableCell: TableViewCell {

    // MARK: - Properties
    fileprivate lazy var headerScreen: UIView = {
        HeaderView(header: R.string.localizable.reported().localizedUppercase)
    }()
    fileprivate lazy var titleLabel = makeTitleLabel()
    fileprivate lazy var subTitleLabel = makeSubTitleLabel()

    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear

        let titleView = makeTitleView()

        let contentView = LinearView(items: [
            (headerScreen, 0),
            (titleView, 5)
        ], bottomConstraint: true)

        contentCell.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        contentCell.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(OurTheme.paddingOverBottomInset)
        }

        titleLabel.setText(R.string.phrase.symptomsGuidanceTitle())
        subTitleLabel.setText(R.string.phrase.symptomsGuidanceSubTitle())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HeaderTableCell {
    fileprivate func makeTitleView() -> UIView {
        let contentView = LinearView(items: [
            (titleLabel, 0), (subTitleLabel, 20)
        ], bottomConstraint: true)

        return CenterView(contentView: contentView, spacing: 30, shrink: true)
    }

    fileprivate func makeTitleLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.apply(font: R.font.atlasGroteskLight(size: 24),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        return label
    }

    fileprivate func makeSubTitleLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.apply(font: R.font.atlasGroteskLight(size: 18),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        return label
    }
}
