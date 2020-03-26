//
//  KeychainStore.swift
//  Autonomy
//
//  Created by thuyentruong on 11/12/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import KeychainAccess
import RxSwift

class KeychainStore {

    // MARK: - Properties
    fileprivate static let accountCoreKey = "account_core"
    fileprivate static func makeEncryptedDBKey(number: String) -> String {
        "autonomy_encrypted_db_key_\(number)"
    }

    fileprivate static let keychain: Keychain = {
        return Keychain(service: Bundle.main.bundleIdentifier!)
            .authenticationPrompt(R.string.localizable.yourAuthorizationIsRequired())
    }()

    // MARK: - Handlers
    // *** seed Core ***
    static func saveToKeychain(_ seedCore: Data, isSecured: Bool) throws {
        Global.log.info("[start] saveToKeychain")
        defer { Global.log.info("[done] saveToKeychain") }

        try removeSeedCoreFromKeychain()

        if isSecured {
            try keychain
                .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                .set(seedCore, key: accountCoreKey)
        } else {
            try keychain.set(seedCore, key: accountCoreKey)
        }
    }

    static func removeSeedCoreFromKeychain() throws {
        Global.log.info("[start] removeSeedCoreFromKeychain")
        defer { Global.log.info("[done] removeSeedCoreFromKeychain") }

        try keychain.remove(accountCoreKey)
    }

    static func getSeedDataFromKeychain() -> Single<Data?> {
        Global.log.info("[start] getSeedDataFromKeychain")

        return Single<Data?>.create(subscribe: { (single) -> Disposable in
            DispatchQueue.global().async {
                do {
                    let seedData = try keychain.getData(accountCoreKey)
                    Global.log.info("[done] getSeedDataFromKeychain")
                    single(.success(seedData))
                } catch {
                    single(.error(error))
                }
            }
            return Disposables.create()
        })
    }
}
