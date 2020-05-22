//
//  Global.swift
//  Autonomy
//
//  Created by thuyentruong on 11/12/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import BitmarkSDK
import Moya
import RxSwift
import RxCocoa
import CoreLocation
import SwiftDate
import Intercom
import OneSignal
import Alamofire

class Global {
    static var current = Global()
    static let `default` = current
    static var volumePressTrack = ""
    static var volumePressTime: Date?
    static var enableDebugRelay = BehaviorRelay<Bool>(value: false)

    var account: Account? {
        cachedAccount = cachedAccount ?? AccountService.getAccountFromKeychain()
        return cachedAccount
    }

    var cachedAccount: Account?

    lazy var accountNumberRelay = BehaviorRelay<String?>(value: account?.getAccountNumber())
    var userDefault: UserDefaults? {
        guard let accountNumber = account?.getAccountNumber()
            else { return nil }
        return UserDefaults.userStandard(for: accountNumber)
    }

    static let backgroundErrorSubject = PublishSubject<Error>()
    lazy var locationManager: CLLocationManager = {
        return CLLocationManager()
    }()

    lazy var userLocationRelay = BehaviorRelay<CLLocation?>(value: locationManager.location)

    lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        //    let dateFormat = ISO8601DateFormatter()
        let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormat.dateFormat = "yyyy-MM-dd'T'H:m:ss.SSSS'Z"

        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            guard let date = dateFormat.date(from: dateString) else {
                throw "cannot decode date string \(dateString)"
            }
            return date
        })
        return decoder
    }()

    func setupCoreData() -> Completable {
        return Completable.create { (event) -> Disposable in
            guard let currentAccount = Global.current.account else {
                event(.error(AppError.emptyCurrentAccount))
                return Disposables.create()
            }

            do {
                try KeychainStore.saveToKeychain(currentAccount.seed.core, isSecured: false)
                event(.completed)
            } catch {
                event(.error(error))
            }
            return Disposables.create()
        }
    }

    let networkLoggerPlugin: [PluginType] = [
        NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(output: { (_, items) in
            for item in items {
                Global.log.info(item)
            }
        })),
        MoyaAuthPlugin(tokenClosure: {
            return AuthService.shared.auth?.jwtToken
        }),
        MoyaVersionPlugin(),
        MoyaLocationPlugin()
    ]

    static let customDayGradation: RelativeFormatter.Style = {
        let customGradation = RelativeFormatter.Gradation([
            .init(.day, threshold: .value(0)),
            .init(.week, threshold: .value(6.5 * RelativeFormatter.Unit.day.factor)),
            .init(.month, threshold: .value(3.5 * 7 * RelativeFormatter.Unit.day.factor)),
            .init(.year, threshold: .value(1.5 * RelativeFormatter.Unit.month.factor))
        ])

        return RelativeFormatter.Style(
                flavours: [.long],
                gradation: customGradation,
                allowedUnits: [.day, .week, .month, .year])
    }()

    func removeCurrentAccount() throws {
        guard Global.current.account != nil else {
            throw AppError.emptyCurrentAccount
        }

        try KeychainStore.removeSeedCoreFromKeychain()

        // clear user data
        Global.current = Global() // reset local variable
        AuthService.shared = AuthService()
        Intercom.logout()
        OneSignal.setSubscription(false)
        OneSignal.deleteTag(Constant.OneSignal.Tags.key)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        ErrorReporting.setUser(bitmarkAccountNumber: nil)
    }
}

func setScore(_ score: Float, in label: Label) {
    label.setText(score.formatScoreInt)
    label.textColor = HealthRisk(from: score)?.color
}

extension UserDefaults {
    static func userStandard(for number: String) -> UserDefaults? {
        return UserDefaults(suiteName: number)
    }

    var enteredBackgroundTime: Date? {
        get { return date(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
}

enum AppError: Error {
    case emptyLocal
    case emptyCurrentAccount
    case emptyUserDefaults
    case emptyJWT
    case noInternetConnection
    case requireAppUpdate(updateURL: URL)

    static func errorByNetworkConnection(_ error: Error) -> Bool {
        guard let error = error as? Self else { return false }
        switch error {
        case .noInternetConnection:
            return true
        default:
            return false
        }
    }
}

enum AccountError: Error {
    case invalidRecoveryKey
}

class CustomMoyaSession: Alamofire.Session {
    static let shared: CustomMoyaSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10 // as seconds
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.allowsCellularAccess = true
        configuration.waitsForConnectivity = true
        return CustomMoyaSession(configuration: configuration)
    }()
}
