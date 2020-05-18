//
//  DonateViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/14/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import BEMCheckBox

class DonateViewController: ViewController, BackNavigator {

    // MARK: - Properties
    fileprivate  lazy var headerScreen: UIView = {
        HeaderView(header: R.string.phrase.donateHeader().localizedUppercase)
    }()
    fileprivate lazy var titleScreen = makeTitleScreen()
    fileprivate lazy var donate1CheckBox = makeDonateCheckboxView(amount: "$1")
    fileprivate lazy var donate5CheckBox = makeDonateCheckboxView(amount: "$5")
    fileprivate lazy var donate20CheckBox = makeDonateCheckboxView(amount: "$20")
    fileprivate lazy var donateOtherCheckBox = makeDonateCheckboxView(amount: R.string.localizable.other_amount())
    fileprivate lazy var donateCheckBoxGroup: BEMCheckBoxGroup = {
        let checkBoxGroup = BEMCheckBoxGroup(checkBoxes: [
            donate1CheckBox.checkBox,
            donate5CheckBox.checkBox,
            donate20CheckBox.checkBox,
            donateOtherCheckBox.checkBox
        ])
        checkBoxGroup.mustHaveSelection = true
        return checkBoxGroup
    }()

    fileprivate lazy var messageLabel = makeMessageLabel()
    fileprivate lazy var backButton = makeLightBackItem()
    fileprivate lazy var nextButton = RightIconButton(title: R.string.localizable.next().localizedUppercase,
                                                      icon: R.image.nextCircleArrow())
    fileprivate lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: nextButton, hasGradient: false)
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func bindViewModel() {
        super.bindViewModel()

        nextButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            switch self.donateCheckBoxGroup.selectedCheckBox {
            case self.donate1CheckBox.checkBox:  self.gotoDonate(amount: 1)
            case self.donate5CheckBox.checkBox:  self.gotoDonate(amount: 5)
            case self.donate20CheckBox.checkBox: self.gotoDonate(amount: 20)
            case self.donateOtherCheckBox.checkBox: self.gotoDonate()
            default:
                break
            }
        }.disposed(by: disposeBag)
    }

    override func setupViews() {
        super.setupViews()

        let donateOptionsView = LinearView(items: [
            (donate1CheckBox, 0),
            (donate5CheckBox, 15),
            (donate20CheckBox, 15),
            (donateOtherCheckBox, 15)
        ], bottomConstraint: true)

        // *** Setup subviews ***
        let paddingContentView = LinearView(
            items: [
                (headerScreen, 0),
                (titleScreen, 0),
                (SeparateLine(height: 1), 3),
                (donateOptionsView, 30),
                (SeparateLine(height: 1), 30),
                (messageLabel, 30)
        ])

        contentView.addSubview(paddingContentView)
        contentView.addSubview(groupsButton)

        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(OurTheme.paddingInset)
        }

        groupsButton.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
        }

        donateCheckBoxGroup.selectedCheckBox = donate5CheckBox.checkBox
    }
}

extension DonateViewController {
    fileprivate func gotoDonate(amount: Int? = nil) {
        var amountNumber = ""
        if let amount = amount {
            amountNumber = "/\(amount)usd"
        }
        guard let donateLink = URL(string: "https://www.paypal.me/AutonomyByBitmark\(amountNumber)") else { return }
        navigator.show(segue: .safariController(donateLink), sender: self, transition: .alert)
    }
}

extension DonateViewController: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        nextButton.isEnabled = donateCheckBoxGroup.selectedCheckBox != nil
    }
}

// MARK: - Setup views
extension DonateViewController {
    func makeTitleScreen() -> CenterView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.donateTitle(),
                    font: R.font.atlasGroteskLight(size: Size.ds(36)),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        let view = CenterView(contentView: label, shrink: true)
        view.snp.makeConstraints { (make) in
            make.height.equalTo(OurTheme.titleHeight)
        }
        return view
    }

    fileprivate func makeDonateCheckboxView(amount: String) -> CheckboxView {
        let checkboxView = CheckboxView(title: amount)
        checkboxView.titleLabel.font = R.font.atlasGroteskLight(size: 30)
        checkboxView.checkBox.delegate = self
        return checkboxView
    }

    fileprivate func makeMessageLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.donateMessage(),
                    font: R.font.atlasGroteskLight(size: 16),
                    themeStyle: .silverColor, lineHeight: 1.25)
        return label
    }
}
