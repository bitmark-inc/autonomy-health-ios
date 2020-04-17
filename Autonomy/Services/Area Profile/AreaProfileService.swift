//
//  AreaProfileService.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class AreaProfileService {
    static var provider = MoyaProvider<AreaProfileAPI>(plugins: Global.default.networkLoggerPlugin)

    static func get() -> Single<AreaProfile> {
        Global.log.info("[start] AreaProfileService.get")

        return provider.rx
            .requestWithRefreshJwt(.get)
            .filterSuccess()
            .map(AreaProfile.self)
    }

    static func get(poiID: String) -> Single<AreaProfile> {
        Global.log.info("[start] ProfileService.get(poiID:)")

        return provider.rx
            .requestWithRefreshJwt(.getPOI(poiID: poiID))
            .filterSuccess()
            .map(AreaProfile.self)
    }
}
