//
//  CenterView.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/26/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift

class CenterView: UIView {

    // MARK: - Properties
    let disposeBag = DisposeBag()

    init(contentView: UIView, spacing: CGFloat? = nil, shrink: Bool = false) {
        super.init(frame: CGRect.zero)

        addSubview(contentView)

        contentView.snp.makeConstraints { (make) in
            let shrinkOffset = shrink ? -20 : 0
            make.width.equalToSuperview().offset(shrinkOffset)
        }

        if let spacing = spacing {
            contentView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.bottom.equalToSuperview()
                    .inset(UIEdgeInsets(top: spacing, left: 0, bottom: spacing, right: 0))
            }
        } else {
            contentView.snp.makeConstraints { (make) in
                make.centerX.centerY.equalToSuperview()
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
