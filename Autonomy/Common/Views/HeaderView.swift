//
//  HeaderView.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/25/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift

class HeaderView: UIView {

    // MARK: - Properties
    let header: String!
    let disposeBag = DisposeBag()
    lazy var headerLabel = makeHeaderLabel()

    init(header: String) {
        self.header = header
        super.init(frame: CGRect.zero)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        let doubleLine1 = makeDoubleLine()
        let doubleLine2 = makeDoubleLine()

        addSubview(doubleLine1)
        addSubview(headerLabel)
        addSubview(doubleLine2)

        doubleLine1.snp.makeConstraints { (make) in
            make.leading.centerY.equalToSuperview()
            make.width.equalTo(120)
        }

        headerLabel.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }

        doubleLine2.snp.makeConstraints { (make) in
            make.top.width.equalTo(doubleLine1)
            make.trailing.equalToSuperview()
        }

        snp.makeConstraints { (make) in
            make.height.equalTo(14)
        }
    }
}

extension HeaderView {
    fileprivate func makeDoubleLine() -> UIView {
        let line1 = makeSingleLine()
        let line2 = makeSingleLine()

        let view = UIView()
        view.addSubview(line1)
        view.addSubview(line2)

        line1.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        line2.snp.makeConstraints { (make) in
            make.top.equalTo(line1.snp.bottom).offset(3)
            make.leading.trailing.equalTo(line1)
            make.bottom.equalToSuperview()

        }

        return view
    }

    fileprivate func makeSingleLine() -> UIView {
        let view = UIView()
        view.backgroundColor = .red

        view.snp.makeConstraints { (make) in
            make.height.equalTo(1)
        }

        themeService.rx
            .bind({ $0.headerLineColor }, to: view.rx.backgroundColor)
            .disposed(by: disposeBag)

        return view
    }

    fileprivate func makeHeaderLabel() -> Label {
        let label = Label()
        label.apply(text: header, font: R.font.domaineSansTextLight(size: 14), themeStyle: .silverTextColor)
        return label
    }
}
