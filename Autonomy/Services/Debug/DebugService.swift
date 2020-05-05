//
//  DebugService.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class DebugService {
    static var provider = MoyaProvider<DebugAPI>(stubClosure: MoyaProvider.immediatelyStub, session: CustomMoyaSession.shared, plugins: Global.default.networkLoggerPlugin)

    static func get() -> Single<Debug> {
        Global.log.info("[start] DebugService.get")

        return provider.rx
            .requestWithRefreshJwt(.get)
            .filterSuccess()
            .map(Debug.self)
    }

    static func get(poiID: String) -> Single<Debug> {
        Global.log.info("[start] DebugService.get(poiID:)")

        return provider.rx
            .requestWithRefreshJwt(.getPOI(poiID: poiID))
            .filterSuccess()
            .map(Debug.self)
    }
}
