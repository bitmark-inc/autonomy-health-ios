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
    static var provider = MoyaProvider<HealthAPI>(session: CustomMoyaSession.shared, plugins: Global.default.networkLoggerPlugin)

    static func getScore() -> Single<Double> {
        Global.log.info("[start] HealthService.getScore")

        return provider.rx
            .requestWithRefreshJwt(.score)
            .filterSuccess()
            .map([String: Double].self)
            .map { $0["score"] ?? 0}
    }
}
