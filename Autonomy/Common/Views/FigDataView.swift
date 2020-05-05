//
//  FigDataView.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/1/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit

class FigDataView: UIView {

    // MARK: - Properties
    lazy var topInfoLabel = makeTopInfoLabel()
    lazy var button = makeNumberButton()

    let topInfo: String!
    let fixedHeight: CGFloat?

    override var intrinsicContentSize: CGSize {
        let labelSize = topInfoLabel.intrinsicContentSize
        let buttonSize = button.intrinsicContentSize

        let viewWidth = [labelSize.width + 3, buttonSize.width].max() ?? 0

        var viewHeight = self.fixedHeight
        if viewHeight == nil {
            viewHeight = [labelSize.height + 2, buttonSize.height].sum()
        }

        return CGSize(width: viewWidth, height: viewHeight!)
    }

    // MARK: - Inits
    init(topInfo: String? = nil, height: CGFloat? = nil) {
        self.topInfo = topInfo
        self.fixedHeight = height

        super.init(frame: .zero)
        addSubview(topInfoLabel)
        addSubview(button)

        topInfoLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-3)
            make.leading.greaterThanOrEqualToSuperview()
            make.bottom.equalTo(button.snp.top).offset(-2)

            if let topInfo = topInfo, topInfo.count >= 17 {
                make.width.equalTo(67)
            }
        }

        button.snp.makeConstraints { (make) in
            make.trailing.bottom.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
        }
    }

    func setValue(_ value: Int) {
        button.setTitle(value.formatNumber, for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FigDataView {
    fileprivate func makeTopInfoLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.textAlignment = .right
        label.apply(
            text: topInfo,
            font: R.font.atlasGroteskLight(size: 9),
            themeStyle: .silverC4TextColor)
        return label
    }

    fileprivate func makeNumberButton() -> UIButton {
        let button = RightIconButton(icon: R.image.crossCircleArrow())
        button.cornerRadius = 15
        button.apply(font: R.font.ibmPlexMonoLight(size: 18),
                     backgroundTheme: .blueRibbonColor)
        button.snp.makeConstraints { (make) in
            make.height.equalTo(30)
        }
        return button
    }
}
