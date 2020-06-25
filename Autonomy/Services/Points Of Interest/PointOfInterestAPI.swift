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
    case monitor(poiID: String)
    case update(poiID: String, alias: String)
    case delete(poiID: String)
    case order(poiIDs: [String])
}

extension PointOfInterestAPI: AuthorizedTargetType, VersionTargetType, LocationTargetType {

    var baseURL: URL {
        return URL(string: Constant.apiServerURL + "/api/accounts/me/pois")!
    }

    var path: String {
        switch self {
        case .get, .monitor: return ""
        case .update(let poiID, _), .delete(let poiID):
            return poiID
        case .order:
            return "order"
        }
    }

    var method: Moya.Method {
        switch self {
        case .get:      return .get
        case .monitor:  return .post
        case .update:   return .patch
        case .delete:   return .delete
        case .order:    return .put
        }
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        var params: [String: Any] = [:]

        switch self {
        case .monitor(let poiID):
            params["poi_id"] = poiID
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case .update(_, let alias):
            params["alias"] = alias
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case .order(let poiIDs):
            params["order"] = poiIDs
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case .get, .delete:
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
