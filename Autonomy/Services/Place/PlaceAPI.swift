//
//  PlaceAPI.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import BitmarkSDK
import Moya

enum PlaceAPI {
    case get(resourceID: String)
    case create(pointOfInterest: PointOfInterest)
}

extension PlaceAPI: AuthorizedTargetType, VersionTargetType, LocationTargetType {

    var baseURL: URL {
        return URL(string: Constant.apiServerURL + "/api/points-of-interest")!
    }

    var path: String {
        return ""
    }

    var method: Moya.Method {
        switch self {
        case .get:
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
        case .get(let resourceID):
            if let localeCode = Locale.current.languageCode {
                params["lang"] = localeCode
            }

            params["resource_id"] = resourceID
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .create(let pointOfInterest):
            params["alias"] = pointOfInterest.alias
            params["address"] = pointOfInterest.address
            let location = pointOfInterest.location
            params["location"] = [
                "latitude" : location.latitude,
                "longitude": location.longitude
            ]

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
