//
//  ServerAssetsService.swift
//  Autonomy
//
//  Created by thuyentruong on 11/22/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class ServerAssetsService {

    static var provider = MoyaProvider<ServerAssetsAPI>(session: CustomMoyaSession.shared, plugins: Global.default.networkLoggerPlugin)

    static func getAppInformation() -> Single<AppInfo> {
        Global.log.info("[start] getAppInformation")

        return provider.rx
            .onlineRequest(.appInformation)
            .filterSuccess()
            .retryWhenTransientError()
            .asSingle()
            .map(AppInfo.self, atKeyPath: "information")
    }
}
