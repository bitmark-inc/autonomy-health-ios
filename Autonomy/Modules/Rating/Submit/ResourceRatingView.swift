//
//  ResourceRatingView.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/8/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import Cosmos

class ResourceRatingView: UIView {

    // MARK: - Properties
    fileprivate lazy var resourceLabel = makeResourceLabel()
    fileprivate lazy var ratingView = makeRatingView()
    fileprivate let disposeBag = DisposeBag()

    fileprivate let resource: String!

    // MARK: - Inits
    init(resource: String) {
        self.resource = resource
        super.init(frame: CGRect.zero)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupViews() {
        let separateLine = SeparateLine(height: 1, themeStyle: .mineShaftBackground)

        addSubview(resourceLabel)
        addSubview(ratingView)
        addSubview(separateLine)

        ratingView.snp.makeConstraints { (make) in
            make.centerY.trailing.equalToSuperview()
            make.width.equalTo(160)
        }

        resourceLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview()
            make.trailing.equalTo(ratingView.snp.leading).offset(-15)
        }

        separateLine.snp.makeConstraints { (make) in
            make.top.equalTo(resourceLabel.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension ResourceRatingView {
    fileprivate func makeResourceLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(
            text: resource.localizedUppercase,
            font: R.font.atlasGroteskLight(size: 14), themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeRatingView() -> UIView {
        let ratingView = CosmosView()
        ratingView.settings.emptyImage = R.image.emptyRatingImg()
        ratingView.settings.filledImage = R.image.yellowRatingImg()
        ratingView.settings.starMargin = 15
        ratingView.settings.totalStars = 5
        ratingView.didTouchCosmos = { (rating) in
            switch rating {
            case 4...5: ratingView.settings.filledImage = R.image.greenRatingImg()
            case 3...3.9:     ratingView.settings.filledImage = R.image.yellowRatingImg()
            case 0.1...2.9: ratingView.settings.filledImage = R.image.redRatingImg()
            default:
                break
            }
        }

        return ratingView
    }
}
