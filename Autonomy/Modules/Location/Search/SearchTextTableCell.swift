//
//  SearchTextTableCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import SwiftRichString

class SearchTextTableCell: TableViewCell {

    // MARK: - Properties
    lazy var placeTextLabel = Label()
    lazy var secondaryTextLabel = Label()

    lazy var placeStyleGroup: StyleXML = {
        let style = Style {
            $0.font = R.font.atlasGroteskLight(size: 16)
            $0.color = themeService.attrs.silverColor
        }

        let highlight = Style {
            $0.color = themeService.attrs.lightTextColor
        }

        return StyleXML(base: style, ["b": highlight])
    }()
    lazy var secondaryStyleGroup: StyleXML = {
        let style = Style {
            $0.font = R.font.atlasGroteskLight(size: 14)
            $0.color = themeService.attrs.silverColor
        }

        let highlight = Style {
            $0.color = themeService.attrs.lightTextColor
        }

        return StyleXML(base: style, ["b": highlight])
    }()

    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .default

        contentCell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0))
        }

        contentCell.addSubview(placeTextLabel)
        contentCell.addSubview(secondaryTextLabel)

        placeTextLabel.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        secondaryTextLabel.snp.makeConstraints { (make) in
            make.top.equalTo(placeTextLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func setData(placeAttributedText: String, secondaryAttributedText: String) {
        placeTextLabel.attributedText = placeAttributedText.set(style: placeStyleGroup)
        secondaryTextLabel.attributedText = secondaryAttributedText.set(style: secondaryStyleGroup)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
