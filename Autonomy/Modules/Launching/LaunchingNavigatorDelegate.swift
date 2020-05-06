//
//  LaunchingNavigatorDelegate.swift
//  Autonomy
//
//  Created by Thuyen Truong on 1/14/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation
import BitmarkSDK
import RxSwift
import RxCocoa
import CoreLocation

protocol LaunchingNavigatorDelegate: ViewController {
    func loadAndNavigate()
    func navigate()
}

extension LaunchingNavigatorDelegate {

    func loadAndNavigate() {
        Single.just(Global.current.account)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] (account) in
                guard let self = self else { return }

                if let account = account {
                    Global.current.cachedAccount = account
                    AccountService.registerIntercom(for: account.getAccountNumber())
                }

                self.navigate()
            }, onError: { (error) in
                loadingState.onNext(.hide)
                Global.log.error(error)
            })
            .disposed(by: disposeBag)
    }

    func navigate() {
        // *** When user doesn't log in
        if Global.current.account == nil {
            loadingState.onNext(.hide)
            gotoSignInWallScreen()
            return
        }

        // *** user logged in
        if LocationPermission.isEnabled() != true {
            gotoPermissionScreen()
        } else {
            NotificationPermission.isEnabled()
                .map { $0 == true }
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] (isEnabled) in
                    guard let self = self else { return }
                    isEnabled ?
                        self.gotoMainScreen() :
                        self.gotoPermissionScreen()

                    Global.current.accountNumberRelay.accept(
                        Global.current.account?.getAccountNumber())
                })
                .disposed(by: disposeBag)
        }

        Global.openAppWithNotification = false
    }
}

// MARK: - Navigator
extension LaunchingNavigatorDelegate {
    fileprivate func gotoMainScreen() {
        let viewModel = MainViewModel()
        navigator.show(segue: .main(viewModel: viewModel), sender: self,
                       transition: .replace(type: .slide(direction: .down)))
    }

    fileprivate func gotoSignInWallScreen() {
        navigator.show(segue: .signInWall, sender: self, transition: .replace(type: .none))
    }

    fileprivate func gotoPermissionScreen() {
        navigator.show(segue: .permission, sender: self, transition: .replace(type: .none) )
    }
}
