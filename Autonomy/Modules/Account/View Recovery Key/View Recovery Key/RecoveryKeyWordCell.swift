//
//  RecoveryKeyWordCell.swift
//  Autonomy
//
//  Created by thuyentruong on 10/21/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import UIKit

class RecoveryKeyWordCell: UICollectionViewCell {
    // MARK: - Properties

    fileprivate lazy var wordLabel = makeWordLabel()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Handlers
    func setData(word: String) {
        wordLabel.text = word
    }

    // MARK: - Setup Views
    func setupViews() {
        addSubview(wordLabel)

        wordLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension RecoveryKeyWordCell {
    fileprivate func makeWordLabel() -> Label {
        let label = Label()
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = true
        label.apply(font: R.font.atlasGroteskLight(size: 48), themeStyle: .lightTextColor)
        return label
    }
}
