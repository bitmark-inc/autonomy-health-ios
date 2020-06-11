//
//  LocationSearchTableCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import SwiftRichString

class LocationSearchTableCell: TableViewCell {

    // MARK: - Properties
    fileprivate lazy var placeTextLabel = makeLabel()
    fileprivate lazy var secondaryTextLabel = makeLabel()
    fileprivate lazy var healthScoreLabel = makeHealthScoreLabel()
    fileprivate lazy var healthScoreView = makeHealthScoreView()

    fileprivate lazy var placeStyleGroup: StyleXML = {
        let style = Style {
            $0.font = R.font.atlasGroteskLight(size: 16)
            $0.color = themeService.attrs.silverColor
        }

        let highlight = Style {
            $0.color = themeService.attrs.lightTextColor
        }

        return StyleXML(base: style, ["b": highlight])
    }()
    fileprivate lazy var secondaryStyleGroup: StyleXML = {
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

        let textView = UIView()
        textView.addSubview(placeTextLabel)
        textView.addSubview(secondaryTextLabel)

        placeTextLabel.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        secondaryTextLabel.snp.makeConstraints { (make) in
            make.top.equalTo(placeTextLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentView.addSubview(healthScoreView)
        contentView.addSubview(textView)

        healthScoreView.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
                .inset(UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0))
        }

        textView.snp.makeConstraints { (make) in
            make.leading.equalTo(healthScoreView.snp.trailing).offset(15)
            make.top.equalTo(healthScoreView)
            make.trailing.equalToSuperview()
        }
    }

    func setData(placeAttributedText: String, secondaryAttributedText: String) {
        placeTextLabel.attributedText = placeAttributedText.set(style: placeStyleGroup)
        secondaryTextLabel.attributedText = secondaryAttributedText.set(style: secondaryStyleGroup)
    }

    func setData(score: Float?) {
        if let score = score {
            healthScoreLabel.setText(score.formatInt)
            healthScoreView.backgroundColor = HealthRisk(from: score)?.color
        } else {
            healthScoreLabel.setText("?")
            healthScoreView.backgroundColor = HealthRisk.zero.color
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LocationSearchTableCell {
    fileprivate func makeHealthScoreView() -> UIView {
        let view = UIView()
        view.addSubview(healthScoreLabel)
        view.layer.cornerRadius = 30
        view.backgroundColor = themeService.attrs.mineShaftBackground
        view.snp.makeConstraints { (make) in
            make.height.width.equalTo(60)
        }

        healthScoreLabel.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }
        return view
    }

    fileprivate func makeHealthScoreLabel() -> Label {
        let label = Label()
        label.apply(text: "?",
                    font: R.font.domaineSansTextLight(size: 24),
                    themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        return label
    }
}
