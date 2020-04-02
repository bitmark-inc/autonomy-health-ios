//
//  SurveyHelpViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/29/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class SurveyHelpViewController: ViewController {

    // MARK: - Properties
    lazy var headerScreen: UIView = {
        HeaderView(header: R.string.localizable.survey().localizedUppercase)
    }()
    lazy var titleScreen = makeTitleScreen()
    lazy var symptomsOptionBox = makeSymptomsOptionBox()
    lazy var assistanceOptionBox = makeAssistanceOptionBox()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - bindViewModel
    override func bindViewModel() {
        super.bindViewModel()

        symptomsOptionBox.button.rx.tap.bind { [weak self] in
            self?.gotoSurveySymptomsScreen()
        }.disposed(by: disposeBag)

        assistanceOptionBox.button.rx.tap.bind { [weak self] in
            self?.gotoAssistanceScreen()
        }.disposed(by: disposeBag)
    }

    // MARK: - Setup views
    override func setupViews() {
        super.setupViews()

        // *** Setup subviews ***
        let paddingContentView = LinearView(items: [
            (headerScreen, 0),
            (titleScreen, 0),
            (SeparateLine(height: 1), 3),
            (symptomsOptionBox, 29),
            (SeparateLine(height: 1), 15),
            (assistanceOptionBox, 29)
        ])

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
extension SurveyHelpViewController {
    fileprivate func gotoSurveySymptomsScreen() {
        let viewModel = SurveySymptomsViewModel()
        navigator.show(segue: .surveySymptoms(viewModel: viewModel), sender: self)
    }

    fileprivate func gotoAssistanceScreen() {
        let viewModel = AssistanceViewModel()
        navigator.show(segue: .assistance(viewModel: viewModel), sender: self)
    }
}


// MARK: - Setup views
extension SurveyHelpViewController {
    fileprivate func makeTitleScreen() -> CenterView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.surveyHelpTitle(),
                    font: R.font.atlasGroteskLight(size: Size.ds(36)),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return CenterView(contentView: label)
    }

    fileprivate func makeSymptomsOptionBox() -> OptionBoxView {
        return OptionBoxView(title: R.string.phrase.surveyHelpSymptoms(),
                             titleTop: 10,
                             description: R.string.phrase.surveyHelpSymptomsDescription(),
                             descTop: 8,
                             btnImage: R.image.nextCircleArrow()!)
    }

    fileprivate func makeAssistanceOptionBox() -> OptionBoxView {
        return OptionBoxView(title: R.string.phrase.surveyHelpAssistance(),
                             titleTop: 10,
                             description: R.string.phrase.surveyHelpAssistanceDescription(),
                             descTop: 8,
                             btnImage: R.image.nextCircleArrow()!)
    }
}
