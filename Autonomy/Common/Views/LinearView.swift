//
//  LinearView.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/26/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import SnapKit

class LinearView: UIView {

    init(_ items: (UIView, CGFloat)..., bottomConstraint: Bool = false) {
        super.init(frame: CGRect.zero)

        for item in items {
            addSubview(item.0)
        }

        for (index, (item, spacing)) in items.enumerated() {
            switch index {
            case 0:
                item.snp.makeConstraints { (make) in
                    make.top.equalToSuperview().offset(spacing)
                    make.leading.trailing.equalToSuperview()
                }

            case 1..<items.count:
                let previousItem = items[index - 1].0
                item.snp.makeConstraints { (make) in
                    make.top.equalTo(previousItem.snp.bottom).offset(spacing)
                    make.leading.trailing.equalToSuperview()
                }
                fallthrough

            case items.count - 1:
                if bottomConstraint {
                    item.snp.makeConstraints { (make) in
                        make.bottom.equalToSuperview()
                    }
                }

            default:
                return
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
