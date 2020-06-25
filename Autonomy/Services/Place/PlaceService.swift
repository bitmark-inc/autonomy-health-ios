//
//  PlaceService.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class PlaceService {
    static var provider = MoyaProvider<PlaceAPI>(session: CustomMoyaSession.shared, plugins: Global.default.networkLoggerPlugin)

    static func create(pointOfInterest: PointOfInterest) -> Single<PointOfInterest> {
        Global.log.info("[start] PlaceService.create(pointOfInterest:)")

        return provider.rx
            .requestWithRefreshJwt(.create(pointOfInterest: pointOfInterest))
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map(PointOfInterest.self)
    }

    static func get(resourceID: String) -> Single<[PointOfInterest]> {
        Global.log.info("[start] PlaceService.get(resourceID:)")

        return provider.rx
            .requestWithRefreshJwt(.get(resourceID: resourceID))
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map([PointOfInterest].self)
    }
}
