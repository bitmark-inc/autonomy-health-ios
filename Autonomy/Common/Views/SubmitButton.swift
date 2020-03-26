//
//  SubmitButton.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/26/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift

class SubmitButton: UIView {

    lazy var nextButton = makeNextButton()
    lazy var backButton = makeBackButton()
    lazy var titleLabel = makeTitleLabel()

    var item: UIButton!

    init(buttonItem: ButtonItemType, title: String? = nil) {
        super.init(frame: CGRect.zero)

        switch buttonItem {
        case .back:     item = backButton
        default:        item = nextButton
        }

        let item1: UIView!
        let item2: UIView!

        switch buttonItem {
        case .back:
            item1 = backButton
            titleLabel.setText(R.string.localizable.back().localizedUppercase)
            item2 = titleLabel

            item = backButton

        case .next:
            titleLabel.setText(R.string.localizable.next().localizedUppercase)
            item1 = titleLabel
            item2 = nextButton
            item = nextButton
        default:
            return
        }

        if let title = title {
            titleLabel.setText(title)
        }

        addSubview(item1)
        addSubview(item2)

        item1.snp.makeConstraints { (make) in
            make.leading.centerY.equalToSuperview()
        }

        item2.snp.makeConstraints { (make) in
            make.leading.equalTo(item1.snp.trailing).offset(10)
            make.centerY.trailing.equalToSuperview()
        }

        snp.makeConstraints { (make) in
            make.height.equalTo(45)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SubmitButton {
    fileprivate func makeNextButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.nextCircleArrow()!, for: .normal)
        return button
    }

    fileprivate func makeTitleLabel() -> Label {
        let label = Label()
        label.apply(font: R.font.domaineSansTextLight(size: 24),
                    themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeBackButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.backCircleArrow()!, for: .normal)
        return button
    }
}
