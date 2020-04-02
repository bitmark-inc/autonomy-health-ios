//
//  LaunchingViewController.swift
//  Autonomy
//
//  Created by Anh Nguyen on 11/12/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import BitmarkSDK
import RxSwift
import RxCocoa

class LaunchingViewController: ViewController, LaunchingNavigatorDelegate {

    lazy var titleScreen = makeTitleScreen()
    lazy var launchPolygonImage = ImageView(image: R.image.onboardingLaunch())
    lazy var securedByBitmarkImage = ImageView(image: R.image.securedByBitmark())

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        loadAndNavigate()
    }

    override func setupViews() {
        super.setupViews()

        // *** Setup subviews ***
        let paddingContentView = UIView()
        paddingContentView.addSubview(titleScreen)
        paddingContentView.addSubview(launchPolygonImage)
        paddingContentView.addSubview(securedByBitmarkImage)

        titleScreen.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(launchPolygonImage.snp.top).offset(-10)
        }

        launchPolygonImage.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(view.height * 0.33)
            make.leading.trailing.equalToSuperview()
        }

        securedByBitmarkImage.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
        }

        contentView.addSubview(paddingContentView)
        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(OurTheme.paddingInset)
        }
    }
}

extension LaunchingViewController {
    fileprivate func makeTitleScreen() -> CenterView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.launchDescription(),
                    font: R.font.atlasGroteskLight(size: Size.ds(64)),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return CenterView(contentView: label)
    }
}
