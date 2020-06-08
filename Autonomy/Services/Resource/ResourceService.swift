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
    static var provider = MoyaProvider<ResourceAPI>(session: CustomMoyaSession.shared, plugins: Global.default.networkLoggerPlugin)

    static func getFullList(poiID: String) -> Single<[Resource]> {
        Global.log.info("[start] ResourceService.getList(poiID:)")

        return provider.rx
            .requestWithRefreshJwt(.fullList(poiID: poiID))
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map([Resource].self)
    }

    static func create(poiID: String, name: String) -> Single<Resource> {
        Global.log.info("[start] ResourceService.create(poiID:, name:)")

        return provider.rx
            .requestWithRefreshJwt(.create(poiID: poiID, name: name))
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map(String.self, atKeyPath: "id")
            .map { Resource(id: $0, name: name) }
    }
}
