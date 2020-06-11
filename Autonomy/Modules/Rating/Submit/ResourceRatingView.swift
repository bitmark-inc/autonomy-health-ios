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

    let resource: Resource!
    fileprivate let initValue: Int!


    // MARK: - Inits
    init(resource: Resource, initValue: Int = 0) {
        self.resource = resource
        self.initValue = initValue
        super.init(frame: CGRect.zero)

        setupViews()
    }

    var currentRating: Double {
        return ratingView.rating
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

        ratingView.rating = Double(initValue)
        adjustRatingColor(rating: Double(initValue))
    }
}

extension ResourceRatingView {
    fileprivate func makeResourceLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(
            text: resource.name.localizedUppercase,
            font: R.font.atlasGroteskLight(size: 14), themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeRatingView() -> CosmosView {
        let ratingView = CosmosView()
        ratingView.settings.emptyImage = R.image.emptyRatingImg()
        ratingView.settings.filledImage = R.image.yellowRatingImg()
        ratingView.settings.starMargin = 15
        ratingView.settings.totalStars = 5
        ratingView.didTouchCosmos = { [weak self] (rating) in
            self?.adjustRatingColor(rating: rating)
        }

        return ratingView
    }

    fileprivate func adjustRatingColor(rating: Double) {
        switch rating {
           case 4...5: ratingView.settings.filledImage = R.image.greenRatingImg()
           case 3...3.9:     ratingView.settings.filledImage = R.image.yellowRatingImg()
           case 0.1...2.9: ratingView.settings.filledImage = R.image.redRatingImg()
           default:
               break
        }
    }
}
