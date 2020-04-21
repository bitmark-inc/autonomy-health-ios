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
            .map([PointOfInterest].self)
    }

    static func create(pointOfInterest: PointOfInterest) -> Single<PointOfInterest> {
        Global.log.info("[start] PointOfInterestService.create(pointOfInterest:)")

        return provider.rx
            .requestWithRefreshJwt(.create(pointOfInterest: pointOfInterest))
            .filterSuccess()
            .map(PointOfInterest.self)
    }

    static func update(poiID: String, alias: String) -> Completable {
        Global.log.info("[start] PointOfInterestService.update(poiID:, alias:)")

        return provider.rx
            .requestWithRefreshJwt(.update(poiID: poiID, alias: alias))
            .filterSuccess()
            .asCompletable()
    }

    static func delete(poiID: String) -> Completable {
        Global.log.info("[start] PointOfInterestService.delete(poiID:)")

        return provider.rx
            .requestWithRefreshJwt(.delete(poiID: poiID))
            .filterSuccess()
            .asCompletable()
    }

    static func order(poiIDs: [String]) -> Completable {
        Global.log.info("[start] PointOfInterestService.order(poiIDs:)")

        return provider.rx
            .requestWithRefreshJwt(.order(poiIDs: poiIDs))
            .filterSuccess()
            .asCompletable()
    }
}
