//
//  BackNavigator.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/26/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit

protocol BackNavigator {
    func makeLightBackItem() -> SubmitButton
}

extension BackNavigator where Self: ViewController {
    func makeLightBackItem() -> SubmitButton {
        let backItem = SubmitButton(buttonItem: .back)
        backItem.item.rx.tap.bind { [weak self] in
            self?.tapToBack()
        }.disposed(by: disposeBag)

        return backItem
    }

    func tapToBack() {
        Navigator.default.pop(sender: self)
    }
}
