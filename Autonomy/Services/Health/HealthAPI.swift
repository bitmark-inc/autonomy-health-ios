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
    case scores(places: [String])
}

extension HealthAPI: AuthorizedTargetType, VersionTargetType, LocationTargetType {

    var baseURL: URL {
        return URL(string: Constant.apiServerURL + "/api")!
    }

    var path: String {
        switch self {
        case .scores: return "scores"
        }
    }

    var method: Moya.Method {
        switch self {
        case .scores:   return .post
        }
    }

    var sampleData: Data {
        if let dataURL = R.file.calculatedScoresJson(), let data = try? Data(contentsOf: dataURL) {
            return data
        }

        return Data()
    }

    var task: Task {
        var params: [String: Any] = [:]

        switch self {
        case .scores(let places):
            let placesParam = places.map { ["address": $0] }
            params = ["places": placesParam]

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
