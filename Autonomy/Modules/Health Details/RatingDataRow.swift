//
//  RatingDataRow.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/5/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit

class RatingDataRow: UIView {

    // MARK: - Properties
    fileprivate let info: String!

    fileprivate lazy var infoLabel = makeInfoLabel()
    fileprivate lazy var numberLabel = makeNumberLabel()
    fileprivate lazy var deltaView = makeDeltaView()
    fileprivate lazy var deltaImageView = makeDeltaImageView()
    fileprivate lazy var deltaLabel = makeDeltaLabel()

    init(info: String) {
        self.info = info
        super.init(frame: CGRect.zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupViews() {
        let numberView = UIView()
        numberView.addSubview(numberLabel)
        numberView.addSubview(deltaView)

        numberLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(5)
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(deltaView.snp.leading)
        }

        deltaView.snp.makeConstraints { (make) in
            make.top.bottom.trailing.equalToSuperview()
        }

        addSubview(infoLabel)
        addSubview(numberView)

        infoLabel.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(numberView.snp.leading)
        }

        numberView.snp.makeConstraints { (make) in
            make.width.equalTo(Constant.lineHealthDataWidth)
            make.top.bottom.trailing.equalToSuperview()
        }
    }
}

extension RatingDataRow {
    fileprivate func makeInfoLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: info, font: R.font.atlasGroteskLight(size: 14),
                    themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeNumberLabel() -> Label {
        let label = Label()
        label.apply(font: R.font.ibmPlexMonoLight(size: 14),
                    themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeDeltaView() -> UIView {
        return RowView(items: [
            (deltaImageView, 0),
            (deltaLabel, 2)
        ], trailingConstraint: true)
    }

    fileprivate func makeDeltaImageView() -> UIImageView {
        return UIImageView()
    }

    fileprivate func makeDeltaLabel() -> Label {
        let label = Label()
        label.font = R.font.ibmPlexMonoLight(size: 18)
        return label
    }
}
