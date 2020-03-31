//
//  BackNavigator.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/26/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit

protocol BackNavigator {
    func makeLightBackItem() -> LeftSubmitButton
}

extension BackNavigator where Self: ViewController {
    func makeLightBackItem() -> LeftSubmitButton {
        let backItem = LeftSubmitButton(
            title: R.string.localizable.back().localizedUppercase,
            icon: R.image.backCircleArrow()!)

        backItem.rxTap.bind { [weak self] in
            self?.tapToBack()
        }.disposed(by: disposeBag)

        return backItem
    }

    func tapToBack() {
        Navigator.default.pop(sender: self)
    }
}
