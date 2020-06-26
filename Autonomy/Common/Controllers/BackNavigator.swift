//
//  BackNavigator.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/26/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import Hero

protocol BackNavigator {
    func makeLightBackItem(withHandler: Bool, animationType: HeroDefaultAnimationType?) -> LeftIconButton
}

extension BackNavigator where Self: ViewController {
    func makeLightBackItem(withHandler: Bool = true,
                           animationType: HeroDefaultAnimationType? = .slide(direction: .right)
    ) -> LeftIconButton {

        let backItem = LeftIconButton(
            title: R.string.localizable.back().localizedUppercase,
            icon: R.image.backCircleArrow()!)

        if withHandler {
            backItem.rx.tap.bind { [weak self] in
                self?.tapToBack(animationType: animationType)
            }.disposed(by: disposeBag)
        }

        backItem.apply(font: R.font.domaineSansTextLight(size: Size.ds(24)),
                       backgroundStyle: .lightTextColor)

        return backItem
    }

    func tapToBack(animationType: HeroDefaultAnimationType?) {
        if (parent as? NavigationController)?.viewControllers.count ?? 0 > 1 {
            Navigator.default.pop(sender: self, animationType: animationType)

        } else {
            let viewModel = MainViewModel()
            navigator.show(segue: .main(viewModel: viewModel), sender: self,
                           transition: .replace(type: .slide(direction: .right)))
        }
    }
}
