//
//  PlaceholderTextView.swift
//  Autonomy
//
//  Created by thuyentruong on 11/12/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import KMPlaceholderTextView

class PlaceholderTextView: KMPlaceholderTextView {
    let disposeBag = DisposeBag()
}

extension PlaceholderTextView {
    func apply(placeholder: String? = nil, font: UIFont?) {
        self.font = font

        if let placeholder = placeholder {
            self.placeholder = placeholder
        }

        backgroundColor = .clear
        placeholderColor = UIColor(hexString: "#828180")!
        themeService.rx
            .bind({ $0.textViewTextColor }, to: rx.textColor)
            .disposed(by: disposeBag)
    }
}
