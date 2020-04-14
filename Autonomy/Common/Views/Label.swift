//
//  Label.swift
//  Autonomy
//
//  Created by thuyentruong on 11/12/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift

class Label: UILabel {

    var lineHeight: CGFloat?
    let disposeBag = DisposeBag()

    func lineHeightMultiple(_ lineHeightMultiple: CGFloat) {
        let attributedString = NSMutableAttributedString(string: text ?? "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.alignment = textAlignment

        // *** Apply attribute to string ***
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        // *** Set Attributed String to your label ***
        attributedText = attributedString
    }
}

extension Label {
    func setText(_ text: String?) {
        self.text = text

        if let lineHeight = lineHeight {
            lineHeightMultiple(lineHeight)
        }
    }

    func apply(text: String? = nil, font: UIFont?, themeStyle: ThemeStyle, lineHeight: CGFloat? = nil) {
        self.text = text
        self.font = font

        switch themeStyle {
        case .lightTextColor:
            themeService.rx
                .bind({ $0.lightTextColor }, to: rx.textColor)
                .disposed(by: disposeBag)

        case .blackTextColor:
            themeService.rx
                .bind({ $0.blackTextColor }, to: rx.textColor)
                .disposed(by: disposeBag)

        case .silverTextColor:
            themeService.rx
                .bind({ $0.silverTextColor }, to: rx.textColor)
                .disposed(by: disposeBag)

        case .silverC4TextColor:
            themeService.rx
                .bind({ $0.silverC4TextColor }, to: rx.textColor)
                .disposed(by: disposeBag)

        case .concordTextColor:
            themeService.rx
                .bind({ $0.concordTextColor }, to: rx.textColor)
                .disposed(by: disposeBag)

        case .silverChaliceColor:
            themeService.rx
                .bind({ $0.silverChaliceColor }, to: rx.textColor)
                .disposed(by: disposeBag)

        default:
            return
        }

        if let lineHeight = lineHeight {
            self.lineHeight = lineHeight
            lineHeightMultiple(lineHeight)
        }
    }
}
