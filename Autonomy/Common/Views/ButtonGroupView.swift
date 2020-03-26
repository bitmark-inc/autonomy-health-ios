//
//  ButtonGroupView.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/26/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit

class ButtonGroupView: UIView {

    fileprivate lazy var gradientLayerView = makeGradientLayerView()
    let viewHeight: CGFloat = 92

    init(button1: UIView, button2: UIView) {
        super.init(frame: CGRect.zero)

        addSubview(gradientLayerView)
        addSubview(button1)
        addSubview(button2)


        button1.snp.makeConstraints { (make) in
            make.leading.bottom.equalToSuperview()
        }

        button2.snp.makeConstraints { (make) in
            make.bottom.trailing.equalToSuperview()
        }

        gradientLayerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        snp.makeConstraints { (make) in
            make.height.equalTo(viewHeight)
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
            UIColor(hexString: "#1B1B1B")!.withAlphaComponent(0).cgColor,
            UIColor(hexString: "#1B1B1B")!.withAlphaComponent(0.6).cgColor,
            UIColor(hexString: "#1B1B1B")!.withAlphaComponent(1).cgColor
        ]
        gradient.locations = [0.0 , 0.35]
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: viewHeight)

        let view = UIView()
        view.backgroundColor = .clear
        view.layer.insertSublayer(gradient, at: 0)
        return view
    }
}
