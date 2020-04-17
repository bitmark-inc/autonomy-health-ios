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
    case get
    case create(pointOfInterest: PointOfInterest)
    case update(poiID: String, alias: String)
    case delete(poiID: String)
}

extension PointOfInterestAPI: AuthorizedTargetType, VersionTargetType, LocationTargetType {

    var baseURL: URL {
        return URL(string: Constant.apiServerURL + "/api/points-of-interest")!
    }

    var path: String {
        switch self {
        case .get, .create: return ""
        case .update(let poiID, _), .delete(let poiID):
            return poiID
        }
    }

    var method: Moya.Method {
        switch self {
        case .get:      return .get
        case .create:   return .post
        case .update:   return .patch
        case .delete:   return .delete
        }
    }

    var sampleData: Data {
        return Data()
    }

    var parameters: [String: Any]? {
        var params: [String: Any] = [:]
        switch self {
        case .create(let pointOfInterest):
            params["alias"] = pointOfInterest.alias
            params["addess"] = pointOfInterest.alias
            let location = pointOfInterest.location
            params["location"] = [
                "latitude" : location.latitude,
                "longitude": location.longitude
            ]

        case .update(_, let alias):
            params["alias"] = alias

        case .get, .delete:
            return nil
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
