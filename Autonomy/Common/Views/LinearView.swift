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

    init(items: [(UIView, CGFloat)], bottomConstraint: Bool = false) {
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

            default:
                return
            }
        }

        // add bottom constraint if needed
        if bottomConstraint {
            items.last?.0.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RowView: UIView {

    init(items: [(UIView, CGFloat)], trailingConstraint: Bool = false) {
        super.init(frame: CGRect.zero)

        for item in items {
            addSubview(item.0)
        }

        for (index, (item, spacing)) in items.enumerated() {
            switch index {
            case 0:
                item.snp.makeConstraints { (make) in
                    make.leading.equalToSuperview().offset(spacing)
                    make.top.bottom.equalToSuperview()
                }

            case 1..<items.count:
                let previousItem = items[index - 1].0
                item.snp.makeConstraints { (make) in
                    make.leading.equalTo(previousItem.snp.trailing).offset(spacing)
                    make.top.bottom.equalToSuperview()
                }

            default:
                return
            }

            item.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
            }
        }

        // add bottom constraint if needed
        if trailingConstraint {
            items.last?.0.snp.makeConstraints { (make) in
                make.trailing.equalToSuperview()
            }
        }


    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
