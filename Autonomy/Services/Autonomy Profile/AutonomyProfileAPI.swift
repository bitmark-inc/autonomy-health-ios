//
//  AutonomyProfileAPI.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import BitmarkSDK
import Moya

enum AutonomyProfileAPI {
    case get
    case getPOI(poiID: String, allResources: Bool)
}

extension AutonomyProfileAPI: AuthorizedTargetType, VersionTargetType, LocationTargetType {

    var baseURL: URL {
        return URL(string: Constant.apiServerURL + "/api/autonomy_profile")!
    }

    var path: String {
        return ""
    }

    var method: Moya.Method {
        return .get
    }

    var sampleData: Data {
        var dataURL: URL?
        switch self {
        case .get:      dataURL = R.file.youAutonomyProfileJson()
        case .getPOI(_, let allResources):
            dataURL = allResources ? R.file.placeAutonomyProfileFullJson() : R.file.placeAutonomyProfileJson()
        }

        if let dataURL = dataURL, let data = try? Data(contentsOf: dataURL) {
            return data
        }
        return Data()
    }

    var task: Task {
        var params: [String: Any] = [:]

        switch self {
        case .getPOI:
            if let localeCode = Locale.current.languageCode {
                params["lang"] = localeCode
            }
        default: break
        }

        switch self {
        case .get:
            params["me"] = true
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .getPOI(let poiID, let allResources):
            params["poi_id"] = poiID
            if allResources { params["all_resources"] = true }
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
