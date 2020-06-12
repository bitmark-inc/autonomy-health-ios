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
        session: CustomMoyaSession.shared, plugins: Global.default.networkLoggerPlugin)
    static var stubProvider = MoyaProvider<AutonomyProfileAPI>(
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

    static func get(poiID: String, allResources: Bool) -> Single<PlaceAutonomyProfile> {
        Global.log.info("[start] AutonomyProfileService.get(poiID:)")

        return stubProvider.rx
            .requestWithRefreshJwt(.getPOI(poiID: poiID, allResources: allResources))
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map(PlaceAutonomyProfile.self)
    }
}
