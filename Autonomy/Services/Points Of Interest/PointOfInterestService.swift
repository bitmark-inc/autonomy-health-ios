//
//  PointOfInterestService.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class PointOfInterestService {
    static var provider = MoyaProvider<PointOfInterestAPI>(session: CustomMoyaSession.shared, plugins: Global.default.networkLoggerPlugin)

    static func get() -> Single<[PointOfInterest]> {
        Global.log.info("[start] PointOfInterestService.get")

        return provider.rx
            .requestWithRefreshJwt(.get)
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map([PointOfInterest].self)
    }

    static func monitor(poiID: String) -> Completable {
        Global.log.info("[start] PointOfInterestService.monitor(poiID:)")

        return provider.rx
            .requestWithRefreshJwt(.monitor(poiID: poiID))
            .filterSuccess()
            .retryWhenTransientError()
            .ignoreElements()
    }

    static func update(poiID: String, alias: String) -> Completable {
        Global.log.info("[start] PointOfInterestService.update(poiID:, alias:)")

        return provider.rx
            .requestWithRefreshJwt(.update(poiID: poiID, alias: alias))
            .filterSuccess()
            .retryWhenTransientError()
            .ignoreElements()
    }

    static func delete(poiID: String) -> Completable {
        Global.log.info("[start] PointOfInterestService.delete(poiID:)")

        return provider.rx
            .requestWithRefreshJwt(.delete(poiID: poiID))
            .filterSuccess()
            .retryWhenTransientError()
            .ignoreElements()
    }

    static func order(poiIDs: [String]) -> Completable {
        Global.log.info("[start] PointOfInterestService.order(poiIDs:)")

        return provider.rx
            .requestWithRefreshJwt(.order(poiIDs: poiIDs))
            .filterSuccess()
            .retryWhenTransientError()
            .ignoreElements()
    }
}
