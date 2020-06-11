//
//  HealthService.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class HealthService {
    static var provider = MoyaProvider<HealthAPI>(stubClosure: MoyaProvider.immediatelyStub, session: CustomMoyaSession.shared, plugins: Global.default.networkLoggerPlugin)

    static func getScores(places: [String]) -> Single<[Float?]> {
        Global.log.info("[start] HealthService.getScores(places:)")
        Global.log.debug("places: \(places)")

        return provider.rx
            .requestWithRefreshJwt(.scores(places: places))
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map([Float?].self, atKeyPath: "results")
    }
}
