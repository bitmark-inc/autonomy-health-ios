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

    static func getList() -> Single<BehaviorList> {
        Global.log.info("[start] BehaviorService.getList")

        return provider.rx
            .requestWithRefreshJwt(.list)
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map(BehaviorList.self)
    }

    static func getFullList() -> Single<BehaviorFullList> {
        Global.log.info("[start] BehaviorService.getFullList")

        return provider.rx
            .requestWithRefreshJwt(.fullList)
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map(BehaviorFullList.self)
    }

    static func create(name: String) -> Single<Behavior> {
        Global.log.info("[start] BehaviorService.create(name:)")

        return provider.rx
            .requestWithRefreshJwt(.create(name: name))
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map(String.self, atKeyPath: "id")
            .map { Behavior(id: $0, name: name) }
    }

    static func report(behaviorKeys: [String]) -> Completable {
        Global.log.info("[start] BehaviorService.report(behaviorKeys:)")

        return provider.rx
            .requestWithRefreshJwt(.report(behaviorKeys: behaviorKeys))
            .filterSuccess()
            .retryWhenTransientError()
            .ignoreElements()
    }

    static func getMetrics() -> Single<SurveyMetrics> {
        Global.log.info("[start] BehaviorService.getMetrics")

        return provider.rx
            .requestWithRefreshJwt(.metrics)
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map(SurveyMetrics.self)
    }
}
