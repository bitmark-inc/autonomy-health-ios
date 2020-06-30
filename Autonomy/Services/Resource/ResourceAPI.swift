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
    case suggestion
    case shortList(poiID: String)
    case fullList(poiID: String)
    case add(poiID: String, resources: [Resource])
    case ratings(poiID: String)
    case rate(poiID: String, ratings: [ResourceRating])
}

extension ResourceAPI: AuthorizedTargetType, VersionTargetType, LocationTargetType {

    var baseURL: URL {
        switch self {
        case .suggestion:
            return URL(string: Constant.apiServerURL + "/api/resources")!

        case .shortList(let poiID), .fullList(let poiID),
             .add(let poiID, _),
             .ratings(let poiID), .rate(let poiID, _):

            return URL(string: Constant.apiServerURL + "/api/points-of-interest/\(poiID)")!

        }
    }

    var path: String {
        switch self {
        case .suggestion:
            return ""
        case .shortList, .fullList, .add:
            return "resources"
        case .ratings, .rate:
            return "resource-ratings"
        }
    }

    var method: Moya.Method {
        switch self {
        case .shortList, .fullList, .ratings:
            return .get
        case .add:
            return .post
        case .rate:
            return .put
        case .suggestion:
            return .get
        }
    }

    var sampleData: Data {
        var dataURL: URL?
        switch self {
        case .shortList: dataURL = R.file.resourcesShortJson()
        case .fullList: dataURL = R.file.resourcesFullJson()
        case .add:      dataURL = R.file.resourcesAddPoiJson()
        case .ratings:  dataURL = R.file.resourceRatingsJson()
        default:
            break
        }

        if let dataURL = dataURL, let data = try? Data(contentsOf: dataURL) {
            return data
        }
        return Data()
    }

    var task: Task {
        var params: [String: Any] = [:]

        if let localeCode = Locale.current.languageCode {
            params["lang"] = localeCode
        }

        switch self {
        case .suggestion:
            params["suggestion"] = true
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .shortList:
            params["important"] = true
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .fullList:
            params["include_added"] = true
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .add(_, let resources):
            var resourceIDs = [String]()
            var newResourceNames = [String]()
            resources.forEach {
                $0.id.isNotEmpty ? resourceIDs.append($0.id) :newResourceNames.append($0.name)
            }

            params["resource_ids"] = resourceIDs
            params["new_resource_names"] = newResourceNames

            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case .ratings:
            return .requestParameters(parameters: params, encoding: URLEncoding.default)

        case .rate(_, let ratings):
            let ratingsParam = ratings.map {
                [
                    "resource": ["id" : $0.resource.id],
                    "score": $0.score
                ]
            }

            params["ratings"] = ratingsParam
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
