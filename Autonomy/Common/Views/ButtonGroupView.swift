//
//  ButtonGroupView.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/26/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift

class ButtonGroupView: UIView {

    fileprivate lazy var gradientLayerView = makeGradientLayerView()
    let viewHeightWithGradient: CGFloat = 117
    fileprivate let defaultBackgroundColor = UIColor(hexString: "#000")!
    fileprivate let disposeBag = DisposeBag()

    init(button1: UIView, button2: UIView? = nil, hasGradient: Bool = false, button1SpacePercent: Float = 0.5) {
        super.init(frame: CGRect.zero)

        let buttonsLine = UIView()
        buttonsLine.addSubview(button1)

        button1.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(button1SpacePercent)
        }

        if let button2 = button2 {
            buttonsLine.addSubview(button2)
            button2.snp.makeConstraints { (make) in
                make.top.bottom.trailing.equalToSuperview()
                make.width.lessThanOrEqualToSuperview().multipliedBy(1 - button1SpacePercent)
            }
        }

        addSubview(buttonsLine)
        buttonsLine.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
                .inset(OurTheme.paddingInset)
        }

        if hasGradient {
            insertSubview(gradientLayerView, belowSubview: buttonsLine)
            gradientLayerView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }

            snp.makeConstraints { (make) in
                make.height.equalTo(viewHeightWithGradient)
            }
        } else {
            backgroundColor = themeService.attrs.background
            buttonsLine.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(OurTheme.paddingInset.top)
            }
        }
    }

    func attachSeparateLine() {
        let separateLine = SeparateLine(height: 1, themeStyle: .mineShaftBackground)
        addSubview(separateLine)

        separateLine.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ButtonGroupView {
    fileprivate func makeGradientLayerView() -> UIView {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [
            defaultBackgroundColor.withAlphaComponent(0).cgColor,
            defaultBackgroundColor.withAlphaComponent(0.6).cgColor,
            defaultBackgroundColor.withAlphaComponent(1).cgColor
        ]
        gradient.locations = [0.0 , 0.22, 0.45]
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: viewHeightWithGradient)

        let view = UIView()
        view.backgroundColor = .clear
        view.layer.insertSublayer(gradient, at: 0)
        return view
    }

    func apply(backgroundStyle: ThemeStyle) {
        switch backgroundStyle {
        case .codGrayBackground:
            themeService.rx
                .bind({ $0.codGrayBackground }, to: rx.backgroundColor)
                .disposed(by: disposeBag)

        default:
            break
        }
    }
}
