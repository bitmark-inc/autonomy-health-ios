//
//  ResourceAPI.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/8/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation
import Moya

enum ResourceAPI {
    case fullList(poiID: String)
    case create(poiID: String, name: String)
}

extension ResourceAPI: AuthorizedTargetType, VersionTargetType, LocationTargetType {

    var baseURL: URL {
        switch self {
        case .fullList(let poiID), .create(let poiID, _):
            return URL(string: Constant.apiServerURL + "/api/points-of-interest/\(poiID)/resources")!

        }
    }

    var path: String {
        return ""
    }

    var method: Moya.Method {
        switch self {
        case .fullList:
            return .get
        case .create:
            return .post
        }
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        var params: [String: Any] = [:]

        switch self {
        case .fullList:
            params["all"] = true

            if let localeCode = Locale.current.languageCode {
                params["lang"] = localeCode
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .create(_, let name):
            params["name"] = name
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }

    var headers: [String: String]? {
        return [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}
