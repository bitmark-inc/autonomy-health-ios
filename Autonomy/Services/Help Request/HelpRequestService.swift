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
    static var provider = MoyaProvider<HelpRequestAPI>(plugins: Global.default.networkLoggerPlugin)

    static func create(helpRequest: HelpRequest) -> Single<HelpRequest> {
        Global.log.info("[start] HelpRequestService.create(helpRequest:)")

        return provider.rx
            .requestWithRefreshJwt(.create(helpRequest: helpRequest))
            .filterSuccess()
            .map(HelpRequest.self)
    }
}
