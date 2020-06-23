//
//  HealthDataHeaderView.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/22/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit

class HealthDataHeaderView: UIView {

    // MARK: - Properties
    fileprivate lazy var header1Label = makeHeaderLabel()
    fileprivate lazy var header2Label = makeHeaderLabel()
    fileprivate lazy var header3Label = makeHeaderLabel()

    init(_ header1: String, _ header2: String, _ header3: String, hasDot: Bool = false) {
        super.init(frame: CGRect.zero)

        header1Label.setText(header1)
        header2Label.setText(header2)
        header3Label.setText(header3)

        addSubview(header1Label)
        addSubview(header2Label)
        addSubview(header3Label)

        header2Label.textAlignment = .right
        header3Label.textAlignment = .right

        header1Label.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(hasDot ? 30.0 : 0.0)
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(header2Label.snp.leading)
        }

        header2Label.snp.makeConstraints { (make) in
            make.width.equalTo(70)
            make.top.bottom.equalTo(header3Label)
        }

        header3Label.snp.makeConstraints { (make) in
            make.width.equalTo(Size.dw(105))
            make.leading.equalTo(header2Label.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func makeHeaderLabel() -> Label {
        let label = Label()
        label.apply(font: R.font.domaineSansTextLight(size: 10), themeStyle: .silverColor)
        return label
    }
}
