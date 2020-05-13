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
    lazy var redButton = makeHealthButton(healthRisk: .high)
    lazy var yellowButton = makeHealthButton(healthRisk: .moderate)
    lazy var greenButton = makeHealthButton(healthRisk: .low)

    let buttonWidth: CGFloat = Size.dw(105)

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func bindViewModel() {
        super.bindViewModel()

        redButton.rx.tap.bind { [weak self] in
            self?.gotoReportSymptomsScreen()
        }.disposed(by: disposeBag)

        yellowButton.rx.tap.bind { [weak self] in
            self?.gotoReportBehaviorScreen()
        }.disposed(by: disposeBag)

        greenButton.rx.tap.bind { [weak self] in
            self?.gotoReportBehaviorScreen()
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
            make.height.equalTo(OurTheme.titleHeight)
        }
        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(OurTheme.paddingInset)
        }
    }
}

// MARK: - Navigator
extension HealthSurveyViewController {
    fileprivate func gotoReportSymptomsScreen() {
        let viewModel = SurveySymptomsViewModel()
        navigator.show(segue: .surveySymptoms(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoReportBehaviorScreen() {
        let viewModel = SurveyBehaviorsViewModel()
        navigator.show(segue: .surveyBehaviors(viewModel: viewModel), sender: self)
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
                    font: R.font.atlasGroteskLight(size: Size.ds(36)),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return CenterView(contentView: label)
    }

    fileprivate func makeHealthButton(healthRisk: HealthRisk) -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = buttonWidth / 2
        button.backgroundColor = healthRisk.color
        button.snp.makeConstraints { (make) in
            make.width.height.equalTo(buttonWidth)
        }
        return button
    }
}
