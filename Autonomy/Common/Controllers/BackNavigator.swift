//
//  BackNavigator.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/26/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit

protocol BackNavigator {
    func makeLightBackItem() -> LeftIconButton
}

extension BackNavigator where Self: ViewController {
    func makeLightBackItem() -> LeftIconButton {
        let backItem = LeftIconButton(
            title: R.string.localizable.back().localizedUppercase,
            icon: R.image.backCircleArrow()!)

        backItem.rx.tap.bind { [weak self] in
            self?.tapToBack()
        }.disposed(by: disposeBag)
    
        backItem.apply(font: R.font.domaineSansTextLight(size: 24),
                       backgroundTheme: .lightTextColor)

        return backItem
    }

    func tapToBack() {
        Navigator.default.pop(sender: self)
    }
}
