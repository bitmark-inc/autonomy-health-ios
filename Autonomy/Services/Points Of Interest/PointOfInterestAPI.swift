//
//  PointOfInterestAPI.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import BitmarkSDK
import Moya

enum PointOfInterestAPI {
    case update(pointOfInterests: [PointOfInterest])
}

extension PointOfInterestAPI: AuthorizedTargetType, VersionTargetType, LocationTargetType {

    var baseURL: URL {
        return URL(string: Constant.apiServerURL + "/api/points-of-interest")!
    }

    var path: String {
        switch self {
        case .update:
            return ""
        }
    }

    var method: Moya.Method {
        switch self {
        case .update:           return .put
        }
    }

    var sampleData: Data {
        return Data()
    }

    var parameters: [String: Any]? {
        var params: [String: Any] = [:]
        switch self {
        case .update(let pointOfInterests):
            let pointsOfInterestData = pointOfInterests.map { ["alias": $0.alias, "location": ["latitude": $0.location.latitude, "longitude": $0.location.longitude]] }
            params["points_of_interest"] = pointsOfInterestData
        }
        return params
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
