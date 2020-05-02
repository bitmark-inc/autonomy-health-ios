//
//  FigLabel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/1/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit

class FigLabel: UIView {

    // MARK: - Properties
    let text: String!
    let fixedHeight: CGFloat!
    lazy var label = makeLabel()

    override var intrinsicContentSize: CGSize {
        return CGSize(width: label.intrinsicContentSize.width, height: fixedHeight)
    }

    // MARK: - Inits
    init(_ text: String, height: CGFloat = 42) {
        self.text = text
        self.fixedHeight = height

        super.init(frame: .zero)

        let labelView = UIView()
        labelView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.edges.centerY.equalToSuperview()
        }

        addSubview(labelView)
        labelView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(30)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func makeLabel() -> UILabel {
        let label = Label()
        label.apply(
            text: text,
            font: R.font.ibmPlexMonoLight(size: 18),
            themeStyle: .blackTextColor)
        return label
    }
}
