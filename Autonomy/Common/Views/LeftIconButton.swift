//
//  LeftIconButton.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/23/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LeftIconButton: UIButton {

    // MARK: - Properties
    fileprivate let disposeBag = DisposeBag()

    init(title: String? = nil, icon: UIImage?, spacing: CGFloat = Size.dw(15)) {
        super.init(frame: CGRect.zero)

        setTitle(title, for: .normal)
        setImage(icon, for: .normal)

        contentHorizontalAlignment = .leading
        titleEdgeInsets = UIEdgeInsets(top: 2, left: spacing, bottom: 0, right: -spacing)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LeftIconButton {
    func apply(font: UIFont?, textStyle: ThemeStyle? = nil, backgroundStyle: ThemeStyle? = nil) {
        titleLabel?.font = font

        if let textStyle = textStyle {
            switch textStyle {
            case .silverColor:
                themeService.rx
                    .bind({ $0.silverColor }, to: rx.tintColor)
                    .disposed(by: disposeBag)
            default:
                break
            }
        }

        if let backgroundStyle = backgroundStyle {
            switch backgroundStyle {
            case .blueRibbonColor:
                themeService.rx
                    .bind({ $0.blueRibbonColor }, to: rx.backgroundColor)
                    .bind({ $0.lightTextColor }, to: rx.tintColor)
                    .disposed(by: disposeBag)

            case .silverColor:
                themeService.rx
                    .bind({ $0.silverColor }, to: rx.backgroundColor)
                    .bind({ $0.lightTextColor }, to: rx.tintColor)
                    .disposed(by: disposeBag)

            default:
                break
            }
        }
    }
}
