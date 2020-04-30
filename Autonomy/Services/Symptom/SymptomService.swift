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

    static func getList() -> Single<[Symptom]> {
        Global.log.info("[start] SymptomService.getList")

        return provider.rx
            .requestWithRefreshJwt(.list)
            .filterSuccess()
            .map([Symptom].self, atKeyPath: "symptoms")
    }

    static func create(survey: Survey) -> Single<Symptom> {
        Global.log.info("[start] SymptomService.create(survey:)")

        return provider.rx
            .requestWithRefreshJwt(.create(survey: survey))
            .filterSuccess()
            .map(String.self, atKeyPath: "id")
            .map { Symptom(id: $0, name: survey.name, desc: survey.desc) }
    }

    static func report(symptomKeys: [String]) -> Completable {
        Global.log.info("[start] SymptomService.report(symptomKeys:)")

        return provider.rx
            .requestWithRefreshJwt(.report(symptomKeys: symptomKeys))
            .filterSuccess()
            .asCompletable()
    }
}
