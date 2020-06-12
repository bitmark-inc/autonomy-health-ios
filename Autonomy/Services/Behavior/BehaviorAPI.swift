//
//  BehaviorAPI.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import Moya

enum BehaviorAPI {
    case list
    case fullList
    case create(name: String)
    case report(behaviorKeys: [String])
    case metrics
}

extension BehaviorAPI: AuthorizedTargetType, VersionTargetType, LocationTargetType {

    var baseURL: URL {
        switch self {
        case .list, .fullList:
            return URL(string: Constant.apiServerURL + "/api/v2/behaviors")!
        case .metrics:
            return URL(string: Constant.apiServerURL + "/api/metrics/behavior")!
        default:
            return URL(string: Constant.apiServerURL + "/api/behaviors")!
        }
    }

    var path: String {
        switch self {
        case .list, .fullList, .create, .metrics:
            return ""
        case .report:
            return "report"
        }
    }

    var method: Moya.Method {
        switch self {
        case .list, .fullList, .metrics:
            return .get
        case .create, .report:
            return .post
        }
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        var params: [String: Any] = [:]

        switch self {
        case .list, .fullList:
            if let localeCode = Locale.current.languageCode {
                params["lang"] = localeCode
            }
        default: break
        }

        switch self {
        case .list:
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .fullList:
            params["all"] = true
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .create(let name):
            params["name"] = name
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case .report(let behaviorKeys):
            params["behaviors"] = behaviorKeys
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case .metrics:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}
