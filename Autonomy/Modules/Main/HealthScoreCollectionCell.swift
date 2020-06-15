//
//  HealthScoreCollectionCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/3/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift

class HealthScoreCollectionCell: UICollectionViewCell {

    // MARK: - Properties
    fileprivate lazy var healthTriangle = makeHealthTriangle()
    fileprivate lazy var nameLabel = makeNameLabel()
    fileprivate lazy var nameTextField = makeNameTextField()
    fileprivate lazy var deleteButton = makeDeleteButton()

    fileprivate var poiID: String?
    weak var delegate: LocationDelegate?

    static let space: CGFloat = 45
    fileprivate let disposeBag = DisposeBag()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        bindEvents()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.poiID = nil
    }

    fileprivate func bindEvents() {
        addGestureRecognizer(makeLongPressGesture())
    }

    func setData(poi: PointOfInterest) {
        self.poiID = poi.id
        healthTriangle.updateLayout(score: poi.score ?? 0, animate: false)
        setName(poi.alias)
    }

    func setData(score: Float) {
        healthTriangle.updateLayout(score: score, animate: false)
        nameLabel.setText(R.string.localizable.you())
    }

    fileprivate func setName(_ name: String) {
        nameLabel.setText(name)
        nameTextField.text = name
    }

    func toggleEditMode(isOn: Bool) {
        nameLabel.isHidden = isOn
        nameTextField.isHidden = !isOn
        deleteButton.isHidden = !isOn
        delegate?.toggleEditMode(isOn: isOn)

        if isOn { nameTextField.becomeFirstResponder() }
        else {    nameTextField.resignFirstResponder() }
    }

    fileprivate func makeLongPressGesture() -> UILongPressGestureRecognizer {
        let longPress = UILongPressGestureRecognizer()
        longPress.rx.event.bind { [weak self] (gesture) in
            guard let self = self,
                gesture.state == .began, self.poiID != nil else { return }
            self.toggleEditMode(isOn: true)
        }.disposed(by: disposeBag)
        return longPress
    }
}

// MARK: - UITextViewDelegate
extension HealthScoreCollectionCell: UITextViewDelegate {
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        endEditing(textView: textView)
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            endEditing(textView: textView)
            return false
        }
        return true
    }

    fileprivate func endEditing(textView: UITextView) {
        toggleEditMode(isOn: false)

        guard let text = textView.text, text.isNotEmpty else {
            textView.text = nameLabel.text
            return
        }

        guard let poiID = poiID, text != nameLabel.text else {
            return
        }

        setName(text)
        delegate?.updatePOI(poiID: poiID, alias: text)
    }

}

// MARK: - setup views
extension HealthScoreCollectionCell {
    fileprivate func setupViews() {
        contentView.addSubview(healthTriangle)
        contentView.addSubview(nameLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(deleteButton)

        healthTriangle.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Self.space)
        }

        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(healthTriangle.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview()
        }

        nameTextField.snp.makeConstraints { (make) in
            make.edges.equalTo(nameLabel)
                .inset(UIEdgeInsets(top: -8, left: 0, bottom: -6, right: 0))
        }

        deleteButton.snp.makeConstraints { (make) in
            make.top.trailing.equalToSuperview()
        }
    }

    fileprivate func makeHealthTriangle() -> HealthScoreTriangle {
        return HealthScoreTriangle(score: nil, width: frame.width)
    }

    fileprivate func makeNameLabel() -> Label {
        let label = Label()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.apply(font: R.font.atlasGroteskLight(size: 14),
                    themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeNameTextField() -> UITextView {
        let textView = UITextView()
        textView.font = R.font.atlasGroteskLight(size: 14)
        textView.autocorrectionType = .no
        textView.isHidden = true
        textView.returnKeyType = .done
        textView.delegate = self
        textView.textAlignment = .center
        textView.inputAccessoryView = makeInputAccessoryView()

        themeService.rx
            .bind( { $0.silverColor }, to: textView.rx.tintColor)
            .bind( { $0.lightTextColor }, to: textView.rx.textColor)
            .bind({ $0.sharkColor }, to: textView.rx.backgroundColor)
            .disposed(by: disposeBag)
        return textView
    }

    fileprivate func makeInputAccessoryView() -> UIView {
        let label = Label()
        label.apply(text: R.string.phrase.locationEditGuidance(),
                    font: R.font.atlasGroteskLight(size: 14),
                    themeStyle: .silverColor)
        label.textAlignment = .center

        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        themeService.rx
            .bind({ $0.background }, to: view.rx.backgroundColor)
            .disposed(by: disposeBag)

        return view
    }

    fileprivate func makeDeleteButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.deleteLocationCell(), for: .normal)
        button.isHidden = true
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 15, right: 0)

        button.rx.tap.bind { [weak self] in
            guard let self = self, let poiID = self.poiID else { return }
            self.delegate?.deletePOI(poiID: poiID)
        }.disposed(by: disposeBag)

        return button
    }
}
