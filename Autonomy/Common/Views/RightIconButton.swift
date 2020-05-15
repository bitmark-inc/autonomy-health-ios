//
//  RightIconButton.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/23/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RightIconButton: UIButton {

    // MARK: - Properties
    fileprivate let disposeBag = DisposeBag()

    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1 : 0.3
        }
    }

    init(title: String? = nil, icon: UIImage?, spacing: CGFloat = Size.dw(15), edgeSpacing: CGFloat = 0) {
        super.init(frame: CGRect.zero)

        setTitle(title, for: .normal)
        setImage(icon, for: .normal)

        // make icon in the right edge
        titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
        contentEdgeInsets = UIEdgeInsets(top: 5, left: edgeSpacing, bottom: 5, right: spacing + edgeSpacing)
        transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)

        titleLabel?.font = R.font.domaineSansTextLight(size: 24)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RightIconButton {
    func apply(font: UIFont?, backgroundTheme: ThemeStyle? = nil) {
        titleLabel?.font = font

        switch backgroundTheme {
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
