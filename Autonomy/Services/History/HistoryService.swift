//
//  HistoryService.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class HistoryService {
    static var provider = MoyaProvider<HistoryAPI>(session: CustomMoyaSession.shared, plugins: Global.default.networkLoggerPlugin)

    static func symptoms(before date: Date?) -> Single<[SymptomsHistory]> {
        Global.log.info("[start] HistoryService.symptoms(before:)")

        return provider.rx
            .requestWithRefreshJwt(.symptoms(before: date))
            .filterSuccess()
            .map([SymptomsHistory].self, atKeyPath: "symptoms_history")
    }

    static func behaviors(before date: Date?) {
        Global.log.info("[start] HistoryService.behaviors(before:)")

        provider.rx
            .requestWithRefreshJwt(.behaviors(before: date))
            .filterSuccess()
            .subscribe { print($0) }
    }

    static func locations(before date: Date?) -> Single<[LocationHistory]> {
        Global.log.info("[start] HistoryService.locations(before:)")

        return provider.rx
            .requestWithRefreshJwt(.locations(before: date))
            .filterSuccess()
            .map([LocationHistory].self, atKeyPath: "locations_history")
    }
}
