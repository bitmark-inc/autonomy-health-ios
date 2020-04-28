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

    static func get() {
        Global.log.info("[start] FormulaService.get")

        provider.rx
            .requestWithRefreshJwt(.get)
            .filterSuccess()
            .subscribe { print($0) }
    }
}
