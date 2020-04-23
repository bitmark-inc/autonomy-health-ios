//
//  TableView.swift
//  OurBeat
//
//  Created by thuyentruong on 10/24/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import RxSwift
import UIKit

class TableView: UITableView {
    let disposeBag = DisposeBag()

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    func setupViews() {
        backgroundColor = .clear
        separatorStyle = .none
        tableFooterView = UIView()

        themeService.rx
            .bind({ $0.separateTableColor }, to: rx.separatorColor)
            .disposed(by: disposeBag)
    }
}
