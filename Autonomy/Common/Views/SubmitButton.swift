//
//  SubmitButton.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/26/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SubmitButton: UIView {

    // MARK: - Properties
    lazy var titleLabel = makeTitleLabel()
    lazy var button = UIButton()

    let titleThemeColor: ThemeStyle!

    fileprivate lazy var tapGestureRecognizer = makeTapGestureRecognizer()
    fileprivate let disposeBag = DisposeBag()

    var isEnabled: Bool = true {
        didSet {
            button.isEnabled = isEnabled
            alpha = isEnabled ? 1 : 0.3
        }
    }

    init(title: String, icon: UIImage, titleThemeColor: ThemeStyle = .lightTextColor) {
        self.titleThemeColor = titleThemeColor

        super.init(frame: CGRect.zero)

        titleLabel.setText(title)
        button.setImage(icon, for: .normal)

        addGestureRecognizer(tapGestureRecognizer)
        addSubview(titleLabel)
        addSubview(button)

        titleLabel.snp.makeConstraints { (make) in
            make.leading.centerY.equalToSuperview()
        }

        button.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
            make.centerY.trailing.equalToSuperview()
        }

        snp.makeConstraints { (make) in
            make.height.equalTo(45)
        }
    }

    var rxTap: ControlEvent<()> {
        return button.rx.tap
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Reactive where Base: SubmitButton {
    /// Bindable sink for `isEnabled` property.
    var isEnabled: Binder<Bool> {
        return Binder(self.base) { submitButton, isEnabled in
            submitButton.button.isEnabled = isEnabled
            submitButton.alpha = isEnabled ? 1 : 0.3
        }
    }
}

extension SubmitButton {
    fileprivate func makeTitleLabel() -> Label {
        let label = Label()
        label.apply(font: R.font.domaineSansTextLight(size: 24),
                    themeStyle: titleThemeColor)
        return label
    }

    fileprivate func makeTapGestureRecognizer() -> UITapGestureRecognizer {
        let tapGestureRecognizer = UITapGestureRecognizer()
        isUserInteractionEnabled = true
        tapGestureRecognizer.rx.event.bind { [weak self] (_) in
            guard let button = self?.button, button.isEnabled else { return }
            button.sendActions(for: .touchUpInside)
        }.disposed(by: disposeBag)
        return tapGestureRecognizer
    }
}
