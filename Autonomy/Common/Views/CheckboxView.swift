//
//  CheckboxView.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/26/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import SnapKit
import BEMCheckBox

class CheckboxView: UIView {

    // MARK: - Properties
    lazy var checkBox = makeCheckBox()
    lazy var titleLabel = makeTitleLabel()

    let title: String!

    init(title: String) {
        self.title = title

        super.init(frame: CGRect.zero)

        setupViews()
    }

    fileprivate func setupViews() {
        addSubview(checkBox)
        addSubview(titleLabel)

        checkBox.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
            make.width.height.equalTo(45)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(checkBox.snp.trailing).offset(15)
            make.top.trailing.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CheckboxView {
    fileprivate func makeCheckBox() -> BEMCheckBox {
        let checkBox = BEMCheckBox()
        checkBox.tintColor = .white
        checkBox.lineWidth = 1
        checkBox.onCheckColor = .white
        checkBox.onTintColor = .white
        checkBox.animationDuration = 0.2
        checkBox.onAnimationType = .bounce
        checkBox.offAnimationType = .bounce
        return checkBox
    }

    fileprivate func makeTitleLabel() -> Label {
        let label = Label()
        label.apply(text: title,
                    font: R.font.atlasGroteskLight(size: 24),
                    themeStyle: .lightTextColor)
        return label
    }
}
