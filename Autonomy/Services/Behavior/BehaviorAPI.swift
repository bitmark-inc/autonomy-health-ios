//
//  BehaviorAPI.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import BitmarkSDK
import Moya

enum BehaviorAPI {
    case list
    case create(survey: Survey)
    case report(behaviorKeys: [String])
}

extension BehaviorAPI: AuthorizedTargetType, VersionTargetType, LocationTargetType {

    var baseURL: URL {
        return URL(string: Constant.apiServerURL + "/api/behaviors")!
    }

    var path: String {
        switch self {
        case .list, .create:    return ""
        case .report:           return "report"
        }
    }

    var method: Moya.Method {
        switch self {
        case .list:     return .get
        case .create:   return .post
        case .report:   return .post
        }
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        var params: [String: Any] = [:]

        switch self {
        case .list:
            if let localeCode = Locale.current.languageCode {
                params["lang"] = localeCode
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .create(let survey):
            params["name"] = survey.name
            params["desc"] = survey.desc
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case .report(let behaviorKeys):
            params["behaviors"] = behaviorKeys
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
