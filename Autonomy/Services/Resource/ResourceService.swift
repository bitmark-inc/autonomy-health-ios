//
//  ResourceService.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/8/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class ResourceService {
    static var provider = MoyaProvider<ResourceAPI>(
        stubClosure: MoyaProvider.immediatelyStub,
        session: CustomMoyaSession.shared, plugins: Global.default.networkLoggerPlugin)

    static func getImportantList(poiID: String) -> Single<[Resource]> {
        Global.log.info("[start] ResourceService.getImportantList(poiID:)")

        return provider.rx
            .requestWithRefreshJwt(.shortList(poiID: poiID))
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map([Resource].self, atKeyPath: "resources")
    }

    static func getFullList(poiID: String) -> Single<[Resource]> {
        Global.log.info("[start] ResourceService.getList(poiID:)")

        return provider.rx
            .requestWithRefreshJwt(.fullList(poiID: poiID))
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map([Resource].self, atKeyPath: "resources")
    }

    static func add(poiID: String, resources: [Resource]) -> Single<[Resource]> {
        Global.log.info("[start] ResourceService.add(poiID:, resources:)")

        return provider.rx
            .requestWithRefreshJwt(.add(poiID: poiID, resources: resources))
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map([Resource].self, atKeyPath: "resources")
    }

    static func getRatings(poiID: String) -> Single<[ResourceRating]> {
        Global.log.info("[start] ResourceService.getRatings(poiID:)")

        return provider.rx
            .requestWithRefreshJwt(.ratings(poiID: poiID))
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map([ResourceRating].self, atKeyPath: "ratings")
    }

    static func rate(poiID: String, ratings: [ResourceRating]) -> Completable {
        Global.log.info("[start] ResourceService.rate(poiID:, ratings:)")

        return provider.rx
            .requestWithRefreshJwt(.rate(poiID: poiID, ratings: ratings))
            .filterSuccess()
            .retryWhenTransientError()
            .ignoreElements()
    }
}
