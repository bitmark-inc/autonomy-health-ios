//
//  AddRow.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/30/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift

class AddRow: UIView {

    // MARK: - Properties
    lazy var addNewLabel = makeAddNewLabel()
    fileprivate let disposeBag = DisposeBag()

    // MARK: - Inits
    init(title: String) {
        super.init(frame: CGRect.zero)

        addNewLabel.setText(title)

        let addImageView = ImageView(image: R.image.search())

        addSubview(addImageView)
        addSubview(addNewLabel)

        addImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(15)
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }

        addNewLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(addImageView.snp.trailing).offset(15)
            make.top.bottom.equalToSuperview()
                .inset(UIEdgeInsets(top: 22, left: 0, bottom: 20, right: 0))
            make.centerY.equalToSuperview()
        }

        themeService.rx
            .bind({ $0.mineShaftBackground }, to: rx.backgroundColor)
            .disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddRow {
    fileprivate func makeAddNewLabel() -> Label {
        let label = Label()
        label.apply(
            font: R.font.atlasGroteskLight(size: 18),
            themeStyle: .concordColor)
        return label
    }
}
