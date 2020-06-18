//
//  Account+Rx.swift
//  Autonomy
//
//  Created by thuyentruong on 11/21/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import BitmarkSDK
import RxSwift
import Intercom

protocol AccountServiceDelegate {
    static func registerIntercom(for accountNumber: String?, metadata: [String: String])

    // Reactive
    static func rxCreateAndSetupNewAccountIfNotExist() -> Completable
    static func rxCreateNewAccount() -> Single<Account>
    static func getAccountFromKeychain() -> Account?
    static func rxGetAccount(phrases: [String]) -> Single<Account>
}

extension AccountServiceDelegate {
    static func registerIntercom(for accountNumber: String?, metadata: [String: String] = [:]) {
        return registerIntercom(for: accountNumber, metadata: metadata)
    }

    static func rxCreateAndSetupNewAccountIfNotExist() -> Completable {
        Completable.deferred {
            guard Global.current.account == nil else {
                return Completable.empty()
            }
            return rxCreateNewAccount()
                .map {
                    Global.current.cachedAccount = $0
                    try Global.current.setupCurrentAccount()
                }
                .asCompletable()
        }
    }
}

class AccountService: AccountServiceDelegate {
    static func registerIntercom(for accountNumber: String?, metadata: [String: String] = [:]) {
        NetworkConnectionManager.shared.doActionWhenConnecting {
            Global.log.info("[start] registerIntercom")
            Intercom.logout()

            if let accountNumber = accountNumber {
                let intercomUserID = "\(Constant.appName)_ios_\(accountNumber.hexDecodedData.sha3(length: 256).hexEncodedString)"
                Intercom.registerUser(withUserId: intercomUserID)
            } else {
                Intercom.registerUnidentifiedUser()
            }

            let userAttributes = ICMUserAttributes()

            var metadata = metadata
            metadata["Service"] = (Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String) ?? ""
            userAttributes.customAttributes = metadata

            Intercom.updateUser(userAttributes)
            Global.log.info("[done] registerIntercom")
        }
    }

    static func rxCreateNewAccount() -> Single<Account> {
        Global.log.info("[start] createNewAccount")

        return Single.just(()).map { try Account() }
    }

    static func getAccountFromKeychain() -> Account? {
        Global.log.info("[start] getAccountFromKeychain")

        do {
            guard let seedCore = try KeychainStore.getSeedDataFromKeychain() else {
                return nil
            }
            let seed = try Seed.fromCore(seedCore, version: .v2)
            return try Account(seed: seed)
        } catch {
            Global.log.error(error)
        }
        return nil
    }

    static func rxGetAccount(phrases: [String]) -> Single<Account> {
        do {
            let account = try Account(recoverPhrase: phrases, language: .english)
            return Single.just(account)
        } catch {
            return Single.error(error)
        }
    }
}
