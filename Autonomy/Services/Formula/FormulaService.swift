//
//  FormulaService.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class FormulaService {
    static var provider = MoyaProvider<FormulaAPI>(session: CustomMoyaSession.shared, plugins: Global.default.networkLoggerPlugin)

    static func get() -> Single<FormulaWeight> {
        Global.log.info("[start] FormulaService.get")

        return provider.rx
            .requestWithRefreshJwt(.get)
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map(FormulaWeight.self)
    }

    static func update(coefficient: Coefficient) -> Completable {
        Global.log.info("[start] FormulaService.update(coefficient:)")

        return provider.rx
            .requestWithRefreshJwt(.update(coefficient: coefficient))
            .filterSuccess()
            .retryWhenTransientError()
            .ignoreElements()
    }

    static func delete() -> Completable {
        Global.log.info("[start] FormulaService.delete")

        return provider.rx
            .requestWithRefreshJwt(.delete)
            .filterSuccess()
            .retryWhenTransientError()
            .ignoreElements()
    }
}
