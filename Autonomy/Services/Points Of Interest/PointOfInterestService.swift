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
    static var provider = MoyaProvider<PointOfInterestAPI>(plugins: Global.default.networkLoggerPlugin)

    static func update(pointOfInterests: [PointOfInterest]) {
        Global.log.info("[start] PointOfInterestService.update(pointOfInterests:)")

         provider.rx
            .requestWithRefreshJwt(.update(pointOfInterests: pointOfInterests))
            .subscribe { print($0) }
    }
}
