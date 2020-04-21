//
//  BehaviorService.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class BehaviorService {
    static var provider = MoyaProvider<BehaviorAPI>(session: CustomMoyaSession.shared, plugins: Global.default.networkLoggerPlugin)

    static func getList() -> Single<[Behavior]> {
        Global.log.info("[start] BehaviorService.getList")

        return provider.rx
            .requestWithRefreshJwt(.list)
            .filterSuccess()
            .map([Behavior].self, atKeyPath: "good_behaviors")
    }

    static func report(behaviorKeys: [String]) -> Completable {
        Global.log.info("[start] BehaviorService.report(behaviorKeys:)")

        return provider.rx
            .requestWithRefreshJwt(.report(behaviorKeys: behaviorKeys))
            .filterSuccess()
            .asCompletable()
    }
}
