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

    fileprivate lazy var headerScreen = HeaderView(header: R.string.phrase.launchName().localizedUppercase)
    fileprivate lazy var titleScreen = makeTitleScreen()
    fileprivate lazy var launchPolygonImage = ImageView(image: R.image.onboardingLaunch())
    fileprivate lazy var securedByBitmarkImage = ImageView(image: R.image.securedByBitmark())

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NetworkConnectionManager.shared.doActionWhenConnecting { [weak self] in
            self?.loadAndNavigate()
        }
    }

    override func setupViews() {
        super.setupViews()

        let securedByBitmarkImageCover = UIView()
        securedByBitmarkImageCover.addSubview(securedByBitmarkImage)
        securedByBitmarkImage.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        // *** Setup subviews ***
        let paddingContentView = UIView()
        paddingContentView.addSubview(headerScreen)
        paddingContentView.addSubview(titleScreen)
        paddingContentView.addSubview(launchPolygonImage)
        paddingContentView.addSubview(securedByBitmarkImageCover)

        headerScreen.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        titleScreen.snp.makeConstraints { (make) in
            make.top.equalTo(headerScreen.snp.bottom).offset(Size.dh(35))
            make.leading.trailing.equalToSuperview()
        }

        launchPolygonImage.snp.makeConstraints { (make) in
            make.top.equalTo(titleScreen.snp.bottom).offset(Size.dh(35))
            make.centerX.equalToSuperview()
            make.bottom.equalTo(securedByBitmarkImageCover.snp.top).offset(-Size.dh(30))
        }

        securedByBitmarkImageCover.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(Size.dh(60))
            make.bottom.equalToSuperview().offset(-Size.dh(102))
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
