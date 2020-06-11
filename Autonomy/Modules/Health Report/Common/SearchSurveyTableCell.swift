//
//  SearchSurveyTableCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/12/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import SwiftRichString

class SearchSurveyTableCell: TableViewCell {

    // MARK: - Properties
    lazy var singleTextLabel = Label()

    lazy var styleGroup: StyleXML = {
        let style = Style {
            $0.font = R.font.atlasGroteskLight(size: 16)
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
                .inset(UIEdgeInsets(top: 30, left: 15, bottom: 30, right: 15))
        }

        contentCell.addSubview(singleTextLabel)

        singleTextLabel.snp.makeConstraints { (make) in
            make.edges.centerY.equalToSuperview()
        }
    }

    func setData(attributedText: String) {
        singleTextLabel.attributedText = attributedText.set(style: styleGroup)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
