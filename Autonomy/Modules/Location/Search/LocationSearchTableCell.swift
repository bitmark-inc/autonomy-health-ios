//
//  LocationSearchTableCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import SwiftRichString
import Cosmos

class LocationSearchTableCell: TableViewCell {

    // MARK: - Properties
    fileprivate lazy var placeTextLabel = makeLabel()
    fileprivate lazy var secondaryTextLabel = makeLabel()
    fileprivate lazy var ratingView = makeRatingView()
    fileprivate lazy var ratingLabel = makeRatingLabel()

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
            $0.font = R.font.atlasGroteskLight(size: 12)
            $0.color = themeService.attrs.silverColor
        }

        let highlight = Style {
            $0.color = themeService.attrs.lightTextColor
        }

        return StyleXML(base: style, ["b": highlight])
    }()

    override func prepareForReuse() {
        super.prepareForReuse()

        ratingView.isHidden = true
        ratingLabel.setText(nil)
    }

    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .default

        contentCell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0))
        }

        let ratingRowView = makeRatingRowView()

        contentCell.addSubview(placeTextLabel)
        contentCell.addSubview(secondaryTextLabel)
        contentCell.addSubview(ratingRowView)

        placeTextLabel.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        secondaryTextLabel.snp.makeConstraints { (make) in
            make.top.equalTo(placeTextLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }

        ratingRowView.snp.makeConstraints { (make) in
            make.top.equalTo(secondaryTextLabel.snp.bottom).offset(17)
            make.leading.bottom.equalToSuperview()
        }
    }

    func setData(placeAttributedText: String, secondaryAttributedText: String) {
        placeTextLabel.attributedText = placeAttributedText.set(style: placeStyleGroup)
        secondaryTextLabel.attributedText = secondaryAttributedText.set(style: secondaryStyleGroup)
    }

    func setData(rating: Float) {
        ratingView.isHidden = false
        ratingView.rating = Double(rating)
        ratingView.customImage(rating: Double(rating))
        if rating == 0 {
            ratingLabel.isHidden = true
        } else {
            ratingLabel.setText(rating.formatRatingScore)
            ratingLabel.isHidden = false
            ratingLabel.textColor = Rating(from: rating).color
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LocationSearchTableCell {
    fileprivate func makeLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        return label
    }

    fileprivate func makeRatingRowView() -> UIView {
        let view = UIView()
        view.addSubview(ratingView)
        view.addSubview(ratingLabel)

        ratingView.snp.makeConstraints { (make) in
            make.leading.centerY.equalToSuperview()
        }

        ratingLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(ratingView.snp.trailing).offset(8)
            make.top.trailing.bottom.equalToSuperview()
        }

        return view
    }

    fileprivate func makeRatingView() -> CosmosView {
        let ratingView = CosmosView()
        ratingView.isHidden = true
        ratingView.settings.starSize = 5
        ratingView.settings.emptyImage = R.image.miniEmptyRatingImg()
        ratingView.settings.starMargin = 5
        ratingView.settings.totalStars = 5
        ratingView.isUserInteractionEnabled = false
        return ratingView
    }

    fileprivate func makeRatingLabel() -> Label {
        let label = Label()
        label.font = R.font.ibmPlexMonoLight(size: 14)
        return label
    }
}
