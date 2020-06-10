//
//  AutonomyProfileService.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class AutonomyProfileService {
    static var provider = MoyaProvider<AutonomyProfileAPI>(
        stubClosure: MoyaProvider.immediatelyStub,
        session: CustomMoyaSession.shared, plugins: Global.default.networkLoggerPlugin)

    static func get() -> Single<YouAutonomyProfile> {
        Global.log.info("[start] AutonomyProfileService.get")

        return provider.rx
            .requestWithRefreshJwt(.get)
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map(YouAutonomyProfile.self)
    }

    static func get(poiID: String) -> Single<PlaceAutonomyProfile> {
        Global.log.info("[start] AutonomyProfileService.get(poiID:)")

        return provider.rx
            .requestWithRefreshJwt(.getPOI(poiID: poiID))
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map(PlaceAutonomyProfile.self)
    }
}
