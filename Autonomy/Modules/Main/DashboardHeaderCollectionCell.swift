//
//  DashboardHeaderCollectionCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/5/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift

class DashboardHeaderCollectionCell: UICollectionViewCell {

    // MARK: - Properties
    fileprivate lazy var nameLabel = makeNameLabel()
    fileprivate lazy var profileButton = makeProfileButton()
    fileprivate lazy var debugButton = makeDebugButton()

    weak var delegate: DashboardDelegate?
    fileprivate let disposeBag = DisposeBag()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(debugButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(profileButton)

        debugButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
        }

        profileButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(-15)
            make.trailing.equalToSuperview()
        }

        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension DashboardHeaderCollectionCell {
    fileprivate func makeNameLabel() -> Label {
        let label = Label()
        label.apply(
            text: Constant.appName.localizedUppercase,
            font: R.font.domaineSansTextLight(size: 14),
            themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeProfileButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.profileButton(), for: .normal)

        button.rx.tap.bind { [weak self] in
            self?.delegate?.gotoProfileScreen()
        }.disposed(by: disposeBag)

        return button
    }

    fileprivate func makeDebugButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.gearIcon(), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 29, right: 29)

        Global.enableDebugRelay
            .map { !$0 }
            .bind(to: button.rx.isHidden)
            .disposed(by: disposeBag)

        button.rx.tap.bind { [weak self] in
            self?.delegate?.gotoDebugScreen()
        }.disposed(by: disposeBag)

        return button
    }
}
