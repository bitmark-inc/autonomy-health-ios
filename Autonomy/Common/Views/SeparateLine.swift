//
//  SeparateLine.swift
//  Autonomy
//
//  Created by thuyentruong on 11/12/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift

class SeparateLine: UIView {

    let disposeBag = DisposeBag()

    init(height: Int, themeStyle: ThemeStyle = .separateTextColor) {
        super.init(frame: CGRect.zero)

        snp.makeConstraints { (make) in
            make.height.equalTo(height)
        }

        switch themeStyle {
        case .separateTextColor:
            themeService.rx
                .bind({ $0.separateTextColor }, to: rx.backgroundColor)
                .disposed(by: disposeBag)

        case .mineShaftBackground:
            themeService.rx
                .bind({ $0.mineShaftBackground }, to: rx.backgroundColor)
                .disposed(by: disposeBag)

        default:
            break
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
