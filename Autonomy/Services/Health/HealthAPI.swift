//
//  HealthAPI.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import Moya

enum HealthAPI {
    case score
}

extension HealthAPI: AuthorizedTargetType, VersionTargetType, LocationTargetType {

    var baseURL: URL {
        return URL(string: Constant.apiServerURL + "/api")!
    }

    var path: String {
        switch self {
        case .score: return "score"
        }
    }

    var method: Moya.Method {
        switch self {
        case .score:   return .get
        }
    }

    var sampleData: Data {
        return Data()
    }

    var parameters: [String: Any]? {
        return nil
    }

    var task: Task {
        if let parameters = parameters {
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
        return .requestPlain
    }

    var headers: [String: String]? {
        return [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}
