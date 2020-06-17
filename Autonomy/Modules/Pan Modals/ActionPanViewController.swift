//
//  ActionPanViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/17/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Moya
import RxSwift
import UIKit
import RxCocoa
import PanModal

class ActionPanViewController: ViewController, PanModalPresentable {

    // *** Override Properties in PanModal ***
    var panScrollable: UIScrollView? {
        return nil
    }

    var shortFormHeight: PanModalHeight {
        view.layoutIfNeeded()
        return .contentHeight(paddingContentView.frame.size.height)
    }

    var longFormHeight: PanModalHeight {
        view.layoutIfNeeded()
        return .contentHeight(paddingContentView.frame.size.height)
    }

    var cornerRadius: CGFloat = 0.0
    var allowsDragToDismiss = false

    // MARK: - Properties
    var paddingContentView: UIView!
    lazy var headerScreen: HeaderView = {
        HeaderView(header: "")
    }()
    lazy var titleLabel = makeTitleLabel()
    lazy var messageLabel = makeMessageLabel()
    lazy var action1Button = makeActionButton()
    lazy var action2Button = makeActionButton()

    var delegate: PanModalDelegate?

    deinit {
        delegate?.donePanModel()
    }

    override func setupViews() {
        super.setupViews()

        themeService.rx
            .bind( { $0.mineShaftBackground }, to: contentView.rx.backgroundColor)
            .disposed(by: disposeBag)

        paddingContentView = LinearView(
        items: [
            (headerScreen, 0),
            (titleLabel, 11),
            (messageLabel, 15),
            (makeButtonGroupView(), 15)
        ], bottomConstraint: true)

        contentView.addSubview(paddingContentView)

        paddingContentView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
                .inset(UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        }
    }
}

extension ActionPanViewController {
    fileprivate func makeTitleLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(
            font: R.font.domaineSansTextLight(size: 18),
            themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return label
    }

    fileprivate func makeMessageLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(
            font: R.font.atlasGroteskLight(size: 18),
            themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return label
    }

    fileprivate func makeButtonGroupView() -> UIView {
        let view = UIView()
        view.addSubview(action1Button)
        view.addSubview(action2Button)

        action1Button.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.leading.top.bottom.equalToSuperview()
        }

        action2Button.snp.makeConstraints { (make) in
            make.leading.equalTo(action1Button.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
        }

        return view
    }

    fileprivate func makeActionButton() -> UIButton {
        let button = UIButton()
        button.titleLabel?.font = R.font.domaineSansTextLight(size: 18)

        themeService.rx
            .bind( { $0.lightTextColor }, to: button.rx.titleColor(for: .normal))
            .disposed(by: disposeBag)

        return button
    }
}
