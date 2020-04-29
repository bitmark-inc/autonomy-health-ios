//
//  HistoryAPI.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import BitmarkSDK
import Moya

enum HistoryAPI {
    case symptoms(before: Date?)
    case behaviors(before: Date?)
    case locations(before: Date?)
}

extension HistoryAPI: AuthorizedTargetType, VersionTargetType, LocationTargetType {

    var baseURL: URL {
        return URL(string: Constant.apiServerURL + "/api/history")!
    }

    var path: String {
        switch self {
        case .symptoms:     return "symptoms"
        case .behaviors:    return "behaviors"
        case .locations:    return "locations"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self {
        case .symptoms(let beforeDate),
             .behaviors(let beforeDate),
             .locations(let beforeDate):
            var params: [String: Any] = ["limit": 20]

            if let beforeDate = beforeDate {
                params["before"] = beforeDate.timeIntervalSince1970
            }

            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        return [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}
