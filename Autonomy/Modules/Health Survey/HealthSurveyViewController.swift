//
//  HealthSurveyViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/27/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class HealthSurveyViewController: ViewController {

    // MARK: - Properties
    lazy var headerScreen: UIView = {
        HeaderView(header: R.string.localizable.survey().localizedUppercase)
    }()
    lazy var titleScreen = makeTitleScreen()
    lazy var redButton = makeHealthButton(color: Constant.HeathColor.red)
    lazy var yellowButton = makeHealthButton(color: Constant.HeathColor.yellow)
    lazy var greenButton = makeHealthButton(color: Constant.HeathColor.green)

    let buttonWidth: CGFloat = 105

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func bindViewModel() {
        super.bindViewModel()

        redButton.rx.tap.bind { [weak self] in
            self?.gotoSurveyHelpScreen()
        }.disposed(by: disposeBag)

        yellowButton.rx.tap.bind { [weak self] in
            self?.gotoMainScreen()
        }.disposed(by: disposeBag)

        greenButton.rx.tap.bind { [weak self] in
            self?.gotoMainScreen()
        }.disposed(by: disposeBag)
    }

    // MARK: - Setup views
    override func setupViews() {
        super.setupViews()

        // *** Setup subviews ***
        let paddingContentView = LinearView(
            items: [
                (headerScreen, 0),
                (titleScreen, 0),
                (SeparateLine(height: 1), 3)
        ])

        let groupsButton = UIStackView(arrangedSubviews: [redButton, yellowButton, greenButton],
                                       axis: .horizontal, spacing: 10)
        paddingContentView.addSubview(groupsButton)

        groupsButton.snp.makeConstraints { (make) in
            make.width.equalTo(buttonWidth * 3 + 10 * 2)
            make.centerX.equalToSuperview()
                make.bottom.equalToSuperview()
        }

        contentView.addSubview(paddingContentView)
        titleScreen.snp.makeConstraints { (make) in
            make.height.equalTo(contentView).multipliedBy(OurTheme.titleHeight)
        }
        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(OurTheme.paddingInset)
        }
    }
}

// MARK: - Navigator
extension HealthSurveyViewController {
    fileprivate func gotoSurveyHelpScreen() {
        navigator.show(segue: .surveyHelp, sender: self)
    }

    fileprivate func gotoMainScreen() {
        let viewModel = MainViewModel()
        navigator.show(segue: .main(viewModel: viewModel), sender: self,
                       transition: .replace(type: .slide(direction: .down)))
    }

}

// MARK: - Setup views
extension HealthSurveyViewController {
    fileprivate func makeTitleScreen() -> CenterView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.surveyTitle(),
                    font: R.font.atlasGroteskLight(size: 36),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return CenterView(contentView: label)
    }

    fileprivate func makeHealthButton(color: UIColor) -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = buttonWidth / 2
        button.backgroundColor = color
        button.snp.makeConstraints { (make) in
            make.width.height.equalTo(buttonWidth)
        }
        return button
    }
}
