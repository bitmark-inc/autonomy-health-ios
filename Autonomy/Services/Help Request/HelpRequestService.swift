//
//  HelpRequestService.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class HelpRequestService {
    static var provider = MoyaProvider<HelpRequestAPI>(session: CustomMoyaSession.shared, plugins: Global.default.networkLoggerPlugin)

    static func create(helpRequest: HelpRequest) -> Completable {
        Global.log.info("[start] HelpRequestService.create(helpRequest:)")

        return provider.rx
            .requestWithRefreshJwt(.create(helpRequest: helpRequest))
            .filterSuccess()
            .asCompletable()
    }

    static func list() -> Single<[HelpRequest]> {
        Global.log.info("[start] HelpRequestService.list()")

        return provider.rx
            .requestWithRefreshJwt(.list)
            .filterSuccess()
            .map([HelpRequest].self, atKeyPath: "result")
    }

    static func get(of helpRequestID: String) -> Single<HelpRequest> {
        Global.log.info("[start] HelpRequestService.get(of:)")

        return provider.rx
            .requestWithRefreshJwt(.get(helpRequestID: helpRequestID))
            .filterSuccess()
            .map(HelpRequest.self, atKeyPath: "result")
    }

    static func give(to helpRequestID: String) -> Completable {
        Global.log.info("[start] HelpRequestService.give(to:)")

        return provider.rx
            .requestWithRefreshJwt(.give(helpRequestID: helpRequestID))
            .filterSuccess()
            .asCompletable()
    }
}
