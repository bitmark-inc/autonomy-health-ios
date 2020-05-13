//
//  AssistanceViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/30/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class AssistanceViewController: ViewController {

    // MARK: - Properties
    lazy var headerScreen: UIView = {
        HeaderView(header: R.string.localizable.assistance().localizedUppercase)
    }()
    lazy var titleScreen = makeTitleScreen()
    lazy var assistanceOptionViews: [OptionBoxView] = {
        return AssistanceKind.allCases.map { makeOptionBoxView(for: $0) }
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - bindViewModel
    override func bindViewModel() {
        super.bindViewModel()

        assistanceOptionViews.forEach { (optionBoxView) in
            optionBoxView.button.rx.tap.bind { [weak self] in
                guard let self = self,
                    let assistanceKind = optionBoxView.attachedValue as? AssistanceKind else { return }
                self.gotoAssistanceNeedItemsScreen(assistanceKind: assistanceKind)
            }.disposed(by: disposeBag)
        }
    }

    // MARK: - Setup views
    override func setupViews() {
        super.setupViews()

        let assistanceOptionViewStack = UIStackView(
            arrangedSubviews: assistanceOptionViews,
            axis: .vertical, spacing: 15.0)

        // *** Setup subviews ***
        let paddingContentView = LinearView(
            items: [
                (headerScreen, 0),
                (titleScreen, 0),
                (SeparateLine(height: 1), 3),
                (assistanceOptionViewStack, 28)
            ]
        )

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
extension AssistanceViewController {
    fileprivate func gotoAssistanceNeedItemsScreen(assistanceKind: AssistanceKind) {
        var helpRequest = HelpRequest()
        helpRequest.subject = assistanceKind.rawValue

        let viewModel = AssistanceAskInfoViewModel(assistanceInfoType: .exactNeeds, helpRequest: helpRequest)
        navigator.show(segue: .assistanceAskInfo(viewModel: viewModel), sender: self)
    }
}

// MARK: - Setup views
extension AssistanceViewController {
    fileprivate func makeTitleScreen() -> CenterView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.assistanceTitle(),
                    font: R.font.atlasGroteskLight(size: Size.ds(36)),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return CenterView(contentView: label)
    }

    fileprivate func makeOptionBoxView(for assistanceKind: AssistanceKind) -> OptionBoxView {
        let optionBoxView = OptionBoxView(title: assistanceKind.title,
                             description: assistanceKind.description,
                             btnImage: R.image.nextCircleArrow()!)
        optionBoxView.attachedValue = assistanceKind
        return optionBoxView
    }
}
