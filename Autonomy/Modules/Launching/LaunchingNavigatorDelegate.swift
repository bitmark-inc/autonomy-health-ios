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
        let existsCurrentAccountSingle = Single<Account?>.deferred {
            if let account = Global.current.account {
                return Single.just(account)
            } else {
                return AccountService.rxExistsCurrentAccount()
            }
        }

        existsCurrentAccountSingle
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] (account) in
                guard let self = self else { return }

                if let account = account {
                    Global.current.account = account
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
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            gotoPermissionScreen()
        case .authorizedAlways, .authorizedWhenInUse:
            gotoHealthSurveyScreen()
        @unknown default:
            break
        }
    }
}

// MARK: - Navigator
extension LaunchingNavigatorDelegate {
    fileprivate func gotoSignInWallScreen() {
        navigator.show(segue: .signInWall, sender: self, transition: .replace(type: .none))
    }

    fileprivate func gotoHealthSurveyScreen() {
        navigator.show(segue: .healthSurvey, sender: self, transition: .replace(type: .none))
    }

    fileprivate func gotoPermissionScreen() {
        navigator.show(segue: .permission, sender: self, transition: .replace(type: .none) )
    }
}
