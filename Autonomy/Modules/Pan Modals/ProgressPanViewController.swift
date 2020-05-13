//
//  ProgressPanViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/13/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Moya
import RxSwift
import UIKit
import RxCocoa
import PanModal
import MaterialProgressBar

class ProgressPanViewController: ViewController, PanModalPresentable {

    // *** Override Properties in PanModal ***
    var panScrollable: UIScrollView? {
        return nil
    }

    var shortFormHeight: PanModalHeight {
        view.layoutIfNeeded()
        return .contentHeight(paddingContentView.frame.size.height + 80)
    }

    var longFormHeight: PanModalHeight {
        view.layoutIfNeeded()
        return .contentHeight(paddingContentView.frame.size.height + 80)
    }

    var cornerRadius: CGFloat = 0.0
    var allowsDragToDismiss = false

    // MARK: - Properties
    var paddingContentView: UIView!
    lazy var headerScreen: HeaderView = {
        HeaderView(header: "")
    }()
    lazy var titleLabel = makeTitleLabel()
    lazy var indeterminateProgressBar = makeIndeterminateProgressBar()

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
            (titleLabel, 26),
            (makeIndeterminateProgressBarView(), 34)
        ], bottomConstraint: true)

        contentView.addSubview(paddingContentView)

        paddingContentView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
                .inset(UIEdgeInsets(top: 30, left: 15, bottom: 50, right: 15))
        }
    }
}

extension ProgressPanViewController {
    fileprivate func makeTitleLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(
            font: R.font.atlasGroteskLight(size: 18),
            themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return label
    }

    fileprivate func makeIndeterminateProgressBarView() -> UIView {
        let view = UIView()
        view.snp.makeConstraints { (make) in
            make.height.equalTo(1)
        }
        view.addSubview(indeterminateProgressBar)
        indeterminateProgressBar.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        return view
    }

    fileprivate func makeIndeterminateProgressBar() -> LinearProgressBar {
        let progressBar = LinearProgressBar()
        progressBar.progressBarColor = UIColor(hexString: "#2DC937")!
        progressBar.backgroundColor = UIColor(hexString: "#828180")
        return progressBar
    }
}
