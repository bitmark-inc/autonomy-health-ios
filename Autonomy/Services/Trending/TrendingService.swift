//
//  TrendingService.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class TrendingService {
    static var provider = MoyaProvider<TrendingAPI>(
        stubClosure: MoyaProvider.immediatelyStub,
        session: CustomMoyaSession.shared, plugins: Global.default.networkLoggerPlugin)

    static func getAutonomyTrending(autonomyObject: AutonomyObject, in datePeriod: DatePeriod) -> Single<[ReportItem]> {
        Global.log.info("[start] TrendingService.getAutonomyTrending(autonomyObject:, in:)")

        return provider.rx
            .requestWithRefreshJwt(.autonomyTrending(autonomyObject: autonomyObject, datePeriod: datePeriod))
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map([ReportItem].self, atKeyPath: "report_items")
    }
}
