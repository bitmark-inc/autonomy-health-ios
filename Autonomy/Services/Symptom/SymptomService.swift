//
//  SymptomService.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class SymptomService {
    static var provider = MoyaProvider<SymptomAPI>(session: CustomMoyaSession.shared, plugins: Global.default.networkLoggerPlugin)

    static func getList() -> Single<SymptomList> {
        Global.log.info("[start] SymptomService.getList")

        return provider.rx
            .requestWithRefreshJwt(.list)
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map(SymptomList.self)
    }

    static func getFullList() -> Single<SymptomFullList> {
        Global.log.info("[start] SymptomService.getFullList")

        return provider.rx
            .requestWithRefreshJwt(.fullList)
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map(SymptomFullList.self)
    }

    static func create(name: String) -> Single<Symptom> {
        Global.log.info("[start] SymptomService.create(name:)")

        return provider.rx
            .requestWithRefreshJwt(.create(name: name))
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map(String.self, atKeyPath: "id")
            .map { Symptom(id: $0, name: name) }
    }

    static func report(symptomKeys: [String]) -> Completable {
        Global.log.info("[start] SymptomService.report(symptomKeys:)")

        return provider.rx
            .requestWithRefreshJwt(.report(symptomKeys: symptomKeys))
            .filterSuccess()
            .retryWhenTransientError()
            .ignoreElements()
    }

    static func getMetrics() -> Single<SurveyMetrics> {
        Global.log.info("[start] SymptomService.getMetrics")

        return provider.rx
            .requestWithRefreshJwt(.metrics)
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map(SurveyMetrics.self)
    }
}
