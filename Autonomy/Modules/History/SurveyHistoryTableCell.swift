//
//  SurveyHistoryTableCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/29/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import SkeletonView

class SurveyHistoryTableCell: TableViewCell {

    // MARK: - Properties
    lazy var attributeLabel = makeAttributeLabel()
    lazy var infoLabel = makeInfoLabel()

    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .default

        contentCell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        }

        let separateLine = SeparateLine(height: 1)

        contentCell.addSubview(attributeLabel)
        contentCell.addSubview(infoLabel)
        contentCell.addSubview(separateLine)

        attributeLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.leading.trailing.equalToSuperview()
        }

        infoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(attributeLabel.snp.bottom).offset(7)
            make.leading.trailing.equalToSuperview()
        }

        separateLine.snp.makeConstraints { (make) in
            make.top.equalTo(infoLabel.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setData(history: SymptomsHistory) {
        let timestamp = history.timestamp.string(withFormat: Constant.TimeFormat.history)

        let attributeText = "\(timestamp) (\(history.location.longitude), \(history.location.latitude))"
        attributeLabel.setText(attributeText)

        let symptomNames = history.symptoms.map { $0.name }
        infoLabel.setText(symptomNames.joined(separator: ", "))
    }

    func setData(history: LocationHistory) {
        let timestamp = history.timestamp.string(withFormat: Constant.TimeFormat.history)
        let locationText = "(\(history.location.longitude), \(history.location.latitude))"
        attributeLabel.setText(timestamp)
        infoLabel.setText(locationText)
    }
}

extension SurveyHistoryTableCell {
    fileprivate func makeAttributeLabel() -> Label {
        let label = Label()
        label.isSkeletonable = true
        label.numberOfLines = 0
        label.apply(font: R.font.atlasGroteskLight(size: 12),
                    themeStyle: .lightTextColor, lineHeight: 1.25)
        return label
    }

    fileprivate func makeInfoLabel() -> Label {
        let label = Label()
        label.isSkeletonable = true
        label.numberOfLines = 0
        label.apply(font: R.font.atlasGroteskLight(size: 14),
                    themeStyle: .silverColor, lineHeight: 1.25)
        return label
    }
}
