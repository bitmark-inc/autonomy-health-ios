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
    fileprivate lazy var resourceLabelCover = makeResourceLabelCover()
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

    func highlight() {
        backgroundColor = themeService.attrs.sharkColor
        ratingView.settings.emptyImage = R.image.highlightEmptyRatingImg()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupViews() {
        backgroundColor = .clear

        let separateLine = SeparateLine(height: 1, themeStyle: .mineShaftBackground)

        let paddingView = UIView()
        paddingView.addSubview(resourceLabel)
        paddingView.addSubview(ratingView)
        paddingView.addSubview(separateLine)

        ratingView.snp.makeConstraints { (make) in
            make.centerY.trailing.equalToSuperview()
        }

        resourceLabel.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(ratingView.snp.leading).offset(-15)
        }

        addSubview(paddingView)
        addSubview(separateLine)

        paddingView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        }

        separateLine.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
        }

        ratingView.rating = Double(initValue)
        ratingView.customImage(rating: Double(initValue))
    }
}

extension ResourceRatingView {
    fileprivate func makeResourceLabelCover() -> UIView {
        let view = UIView()
        view.addSubview(resourceLabel)
        resourceLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
            make.centerY.equalToSuperview()
        }
        return view
    }

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
        ratingView.settings.starSize = 15
        ratingView.settings.starMargin = 15
        ratingView.settings.totalStars = 5
        ratingView.didTouchCosmos = { [weak self] (rating) in
            self?.ratingView.customImage(rating: rating)
        }
        ratingView.snp.makeConstraints { (make) in
            make.width.equalTo(15 * 9)
        }
        return ratingView
    }
}

extension CosmosView {
    func customImage(rating: Double) {
        switch rating {
            case 4...5:      settings.filledImage = R.image.greenRatingImg()
            case 3...3.9:    settings.filledImage = R.image.yellowRatingImg()
            case 0.1...2.9:  settings.filledImage = R.image.redRatingImg()
            default:
                break
        }
    }
}
