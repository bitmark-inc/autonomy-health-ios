//
//  HealthCenterTableCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/9/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift

class HealthCenterTableCell: TableViewCell {

    // MARK: - Properties
    fileprivate lazy var nameLabel = makeNameLabel()
    fileprivate lazy var distanceLabel = makeDistanceLabel()
    fileprivate lazy var addressLabel = makeAddressLabel()
    fileprivate lazy var phoneButton = makePhoneButton()
    fileprivate lazy var mapButton = makeMapButton()

    fileprivate var healthCenter: HealthCenter?
    weak var mapDelegate: MapDelegate?

    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear

        let buttonGroupView = makeButtonGroupView()

        contentCell.addSubview(nameLabel)
        contentCell.addSubview(addressLabel)
        contentCell.addSubview(distanceLabel)
        contentCell.addSubview(buttonGroupView)

        nameLabel.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(-100)
        }

        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(15)
            make.leading.trailing.equalTo(nameLabel)
        }

        distanceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel)
            make.trailing.equalToSuperview()
        }

        buttonGroupView.snp.makeConstraints { (make) in
            make.top.equalTo(addressLabel).offset(-5)
            make.trailing.bottom.equalToSuperview()
        }

        contentCell.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setData(healthCenter: HealthCenter) {
        nameLabel.setText(healthCenter.name)
        distanceLabel.setText(healthCenter.distance.formatDistance)
        addressLabel.setText(healthCenter.address)
        self.healthCenter = healthCenter
    }
}

extension HealthCenterTableCell {
    fileprivate func makeNameLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(font: R.font.atlasGroteskLight(size: 16),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        return label
    }

    fileprivate func makeAddressLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(font: R.font.atlasGroteskLight(size: 12),
                    themeStyle: .silverColor, lineHeight: 1.2)
        return label
    }

    fileprivate func makeDistanceLabel() -> Label {
        let label = Label()
        label.apply(font: R.font.atlasGroteskLight(size: 16),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        return label
    }

    fileprivate func makeButtonGroupView() -> UIView {
        return RowView(items: [
            (phoneButton, 0), (mapButton, 15)
        ], trailingConstraint: true)
    }

    fileprivate func makePhoneButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.callLocation(), for: .normal)
        button.rx.tap.bind { [weak self] in
            guard let self = self, let healthCenter = self.healthCenter,
                let phoneURL = URL(string: "tel://\(healthCenter.phone)") else { return }
            UIApplication.shared.open(phoneURL)
        }.disposed(by: disposeBag)
        return button
    }

    fileprivate func makeMapButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.mapLocation(), for: .normal)
        button.rx.tap.bind { [weak self] in
            guard let self = self, let healthCenter = self.healthCenter else { return }
            self.mapDelegate?.linkMap(address: healthCenter.address)
        }.disposed(by: disposeBag)
        return button
    }
}
