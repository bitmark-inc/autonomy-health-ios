//
//  LocationTableCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/9/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import MGSwipeTableCell

class LocationTableCell: MGSwipeTableCell {

    // MARK: - Properties
    lazy var titleLabel = makeTitleLabel()
    lazy var titleTextField = makeTextFieldLabel()
    lazy var healthScoreLabel = makeHealthScoreLabel()
    lazy var healthScoreView = makeHealthScoreView()

    var poiID: String?
    weak var locationDelegate: LocationDelegate?
    weak var parentLocationListCell: LocationListCell?
    fileprivate let disposeBag = DisposeBag()

    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none

        let contentCell = UIView()
        contentView.addSubview(contentCell)
        contentCell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0))
        }

        contentCell.addSubview(titleTextField)
        contentCell.addSubview(titleLabel)
        contentCell.addSubview(healthScoreView)

        titleTextField.snp.makeConstraints { (make) in
            make.edges.equalTo(titleLabel)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
            make.height.equalTo(60)
        }

        healthScoreView.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel.snp.trailing).offset(15)
            make.centerY.trailing.equalToSuperview()
        }
    }

    func setData(poiID: String, alias: String, score: Int) {
        self.poiID = poiID
        setTitle(alias)
        healthScoreLabel.setText("\(score)")
        healthScoreView.backgroundColor = HealthRisk(from: score)?.color
    }

    func toggleEditMode(isOn: Bool) {
        titleLabel.isHidden = isOn
        titleTextField.isHidden = !isOn

        if isOn {
            titleTextField.perform(#selector(selectAll(_:)), with: nil, afterDelay: 0.5)
            titleTextField.becomeFirstResponder()
        } else {
            titleTextField.resignFirstResponder()
            parentLocationListCell?.toggleAddLocationMode(isOn: true)

            // wait for affecting select TableCell first, before changing isEditMode value
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.parentLocationListCell?.isEditMode = false
            }
        }
    }

    fileprivate func setTitle(_ title: String) {
        titleLabel.setText(title)
        titleTextField.text = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LocationTableCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        toggleEditMode(isOn: false)

        guard let text = textField.text, text.isNotEmpty else {
            textField.text = titleLabel.text
            return
        }

        guard let poiID = poiID, text != titleLabel.text else {
            return
        }
        locationDelegate?.updatePOI(poiID: poiID, alias: text)
        parentLocationListCell?.updatePOI(poiID: poiID, alias: text)
        setTitle(text)
    }

    func overcomeSelectAllIssue() {
        titleTextField.perform(#selector(selectAll(_:)), with: nil, afterDelay: 0)
        titleTextField.perform(#selector(resignFirstResponder), with: nil, afterDelay: 0)
    }
}

// MARK: - Setup views
extension LocationTableCell {
    fileprivate func makeTitleLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(font: R.font.atlasGroteskLight(size: 24), themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeHealthScoreView() -> UIView {
        let view = UIView()
        view.addSubview(healthScoreLabel)
        view.layer.cornerRadius = 30
        view.snp.makeConstraints { (make) in
            make.height.width.equalTo(60)
        }

        healthScoreLabel.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }
        return view
    }

    fileprivate func makeHealthScoreLabel() -> Label {
        let label = Label()
        label.apply(font: R.font.domaineSansTextLight(size: 24), themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeTextFieldLabel() -> UITextField {
        let textfield = UITextField()
        textfield.font = R.font.atlasGroteskLight(size: 24)
        themeService.rx
            .bind( { $0.lightTextColor }, to: textfield.rx.textColor)
            .disposed(by: disposeBag)
        textfield.autocorrectionType = .no
        textfield.isHidden = true
        textfield.returnKeyType = .done
        textfield.delegate = self
        textfield.tintColor = themeService.attrs.silverTextColor
        return textfield
    }
}
