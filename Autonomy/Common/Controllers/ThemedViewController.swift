//
//  ThemedViewController.swift
//  Autonomy
//
//  Created by thuyentruong on 11/12/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxTheme
import SVProgressHUD

class ThemedViewController: UIViewController {

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        themeService.switchThemeType(for: traitCollection.userInterfaceStyle)

        setupViews()
        loadData()
        bindViewModel()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        themeService.switchThemeType(for: traitCollection.userInterfaceStyle)
    }

    func loadData() {}

    func setupViews() {
        themeService.rx
            .bind({ $0.background }, to: view.rx.backgroundColor)
            .disposed(by: disposeBag)
    }

    func setupBackground(backgroundView: UIView) {
        if ((backgroundView as? ImageView) != nil) {
            backgroundView.contentMode = .scaleToFill
        }

        // *** Setup UI in view ***
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    func bindViewModel() {
        loadingState
            .bind(to: SVProgressHUD.rx.state)
            .disposed(by: disposeBag)

        Global.backgroundErrorSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (error) in
                guard let self = self,
                    self == Navigator.getRootViewController()?.viewControllers.last,
                    self.handleIfGeneralError(error: error)
                else {
                    Global.log.error(error)
                    return
                }

                return // already show alert if needed when calling handleIfGeneralError
            })
            .disposed(by: disposeBag)
    }

    func handleIfGeneralError(error: Error) -> Bool {
        guard !AppError.errorByNetworkConnection(error),
            !showIfRequireUpdateVersion(with: error),
            !handleErrorIfAsAFError(error) else {
                return true
        }

        return false
    }
}
