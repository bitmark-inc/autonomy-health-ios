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
    static var provider = MoyaProvider<TrendingAPI>(session: CustomMoyaSession.shared, plugins: Global.default.networkLoggerPlugin)
    static var stubProvider = MoyaProvider<TrendingAPI>(
        stubClosure: MoyaProvider.immediatelyStub,
        session: CustomMoyaSession.shared, plugins: Global.default.networkLoggerPlugin)

    static func getAutonomyTrending(autonomyObject: AutonomyObject, in datePeriod: DatePeriod, granularity: String) -> Single<[ReportItem]> {
        Global.log.info("[start] TrendingService.getAutonomyTrending(autonomyObject:, in:, granularity:)")

        return provider.rx
            .requestWithRefreshJwt(.autonomyTrending(autonomyObject: autonomyObject, datePeriod: datePeriod, granularity: granularity))
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map([ReportItem].self, atKeyPath: "report_items")
    }

    static func getSymptomsTrending(autonomyObject: AutonomyObject, in datePeriod: DatePeriod, granularity: String) -> Single<[ReportItem]> {
        Global.log.info("[start] TrendingService.getSymptomsTrending(autonomyObject:, in:, granularity:)")

        return provider.rx
            .requestWithRefreshJwt(.symptomsTrending(autonomyObject: autonomyObject, datePeriod: datePeriod, granularity: granularity))
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map([ReportItem].self, atKeyPath: "report_items")
    }

    static func getBehaviorsTrending(autonomyObject: AutonomyObject, in datePeriod: DatePeriod, granularity: String) -> Single<[ReportItem]> {
        Global.log.info("[start] TrendingService.getBehaviorsTrending(autonomyObject:, in:, granularity:)")

        return provider.rx
            .requestWithRefreshJwt(.behaviorsTrending(autonomyObject: autonomyObject, datePeriod: datePeriod, granularity: granularity))
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map([ReportItem].self, atKeyPath: "report_items")
    }

    static func getCasesTrending(autonomyObject: AutonomyObject, in datePeriod: DatePeriod, granularity: String) -> Single<[ReportItem]> {
        Global.log.info("[start] TrendingService.getCasesTrending(autonomyObject:, in:, granularity:)")

        return provider.rx
            .requestWithRefreshJwt(.casesTrending(autonomyObject: autonomyObject, datePeriod: datePeriod, granularity: granularity))
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map([ReportItem].self, atKeyPath: "report_items")
    }
}
